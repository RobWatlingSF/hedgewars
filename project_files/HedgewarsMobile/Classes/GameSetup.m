/*
 * Hedgewars-iOS, a Hedgewars port for iOS devices
 * Copyright (c) 2009-2010 Vittorio Giovara <vittorio.giovara@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 2 of the License
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * File created on 10/01/2010.
 */


#import "GameSetup.h"
#import "SDL_uikitappdelegate.h"
#import "SDL_net.h"
#import "PascalImports.h"
#import "CommodityFunctions.h"
#import "NSStringExtra.h"
#import "OverlayViewController.h"

#define BUFFER_SIZE 255     // like in original frontend

@implementation GameSetup
@synthesize systemSettings, gameConfig, savePath;

-(id) initWithDictionary:(NSDictionary *)gameDictionary {
    if (self = [super init]) {
        ipcPort = randomPort();

        // should check they exist and throw and exection if not
        NSDictionary *dictSett = [[NSDictionary alloc] initWithContentsOfFile:SETTINGS_FILE()];
        self.systemSettings = dictSett;
        [dictSett release];

        self.gameConfig = [gameDictionary objectForKey:@"game_dictionary"];
        isNetGame = [[gameDictionary objectForKey:@"netgame"] boolValue];
        NSString *path = [gameDictionary objectForKey:@"savefile"];
        // if path is empty it means i have to create a new file, otherwise i read from that file
        if ([path isEqualToString:@""] == YES) {
            NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
            [outputFormatter setDateFormat:@"yyyy-MM-dd 'at' HH,mm"];
            NSString *newDateString = [outputFormatter stringFromDate:[NSDate date]];
            self.savePath = [SAVES_DIRECTORY() stringByAppendingFormat:@"%@.hws", newDateString];
            [outputFormatter release];
        } else
            self.savePath = path;
    }
    return self;
}

-(void) dealloc {
    [gameConfig release];
    [systemSettings release];
    [savePath release];
    [super dealloc];
}

#pragma mark -
#pragma mark Provider functions
// unpacks team data from the selected team.plist to a sequence of engine commands
-(void) provideTeamData:(NSString *)teamName forHogs:(NSInteger) numberOfPlayingHogs withHealth:(NSInteger) initialHealth ofColor:(NSNumber *)teamColor {
    /*
     addteam <32charsMD5hash> <color> <team name>
     addhh <level> <health> <hedgehog name>
     <level> is 0 for human, 1-5 for bots (5 is the most stupid)
    */

    NSString *teamFile = [[NSString alloc] initWithFormat:@"%@/%@", TEAMS_DIRECTORY(), teamName];
    NSDictionary *teamData = [[NSDictionary alloc] initWithContentsOfFile:teamFile];
    [teamFile release];

    NSString *teamHashColorAndName = [[NSString alloc] initWithFormat:@"eaddteam %@ %@ %@",
                                      [teamData objectForKey:@"hash"], [teamColor stringValue], [teamName stringByDeletingPathExtension]];
    [self sendToEngine: teamHashColorAndName];
    [teamHashColorAndName release];

    NSString *grave = [[NSString alloc] initWithFormat:@"egrave %@", [teamData objectForKey:@"grave"]];
    [self sendToEngine: grave];
    [grave release];

    NSString *fort = [[NSString alloc] initWithFormat:@"efort %@", [teamData objectForKey:@"fort"]];
    [self sendToEngine: fort];
    [fort release];

    NSString *voicepack = [[NSString alloc] initWithFormat:@"evoicepack %@", [teamData objectForKey:@"voicepack"]];
    [self sendToEngine: voicepack];
    [voicepack release];

    NSString *flag = [[NSString alloc] initWithFormat:@"eflag %@", [teamData objectForKey:@"flag"]];
    [self sendToEngine: flag];
    [flag release];

    NSArray *hogs = [teamData objectForKey:@"hedgehogs"];
    for (int i = 0; i < numberOfPlayingHogs; i++) {
        NSDictionary *hog = [hogs objectAtIndex:i];

        NSString *hogLevelHealthAndName = [[NSString alloc] initWithFormat:@"eaddhh %@ %d %@",
                                           [hog objectForKey:@"level"], initialHealth, [hog objectForKey:@"hogname"]];
        [self sendToEngine: hogLevelHealthAndName];
        [hogLevelHealthAndName release];

        NSString *hogHat = [[NSString alloc] initWithFormat:@"ehat %@", [hog objectForKey:@"hat"]];
        [self sendToEngine: hogHat];
        [hogHat release];
    }

    [teamData release];
}

// unpacks ammostore data from the selected ammo.plist to a sequence of engine commands
-(void) provideAmmoData:(NSString *)ammostoreName forPlayingTeams:(NSInteger) numberOfTeams {
    NSString *weaponPath = [[NSString alloc] initWithFormat:@"%@/%@",WEAPONS_DIRECTORY(),ammostoreName];
    NSDictionary *ammoData = [[NSDictionary alloc] initWithContentsOfFile:weaponPath];
    [weaponPath release];
    NSString *update = @"";

    // if we're loading an older version of ammos fill the engine message with 0s
    int diff = CURRENT_AMMOSIZE - [[ammoData objectForKey:@"version"] intValue];
    if (diff != 0)
        update = [NSString stringWithCharacters:(const unichar*)"0000000000000000000000000000000000" length:diff];

    NSString *ammloadt = [[NSString alloc] initWithFormat:@"eammloadt %@%@", [ammoData objectForKey:@"ammostore_initialqt"], update];
    [self sendToEngine: ammloadt];
    [ammloadt release];

    NSString *ammprob = [[NSString alloc] initWithFormat:@"eammprob %@%@", [ammoData objectForKey:@"ammostore_probability"], update];
    [self sendToEngine: ammprob];
    [ammprob release];

    NSString *ammdelay = [[NSString alloc] initWithFormat:@"eammdelay %@%@", [ammoData objectForKey:@"ammostore_delay"], update];
    [self sendToEngine: ammdelay];
    [ammdelay release];

    NSString *ammreinf = [[NSString alloc] initWithFormat:@"eammreinf %@%@", [ammoData objectForKey:@"ammostore_crate"], update];
    [self sendToEngine: ammreinf];
    [ammreinf release];

    // sent twice so it applies to both teams
    NSString *ammstore = [[NSString alloc] initWithString:@"eammstore"];
    for (int i = 0; i < numberOfTeams; i++)
        [self sendToEngine: ammstore];
    [ammstore release];

    [ammoData release];
}

// unpacks scheme data from the selected scheme.plist to a sequence of engine commands
-(NSInteger) provideScheme:(NSString *)schemeName {
    NSString *schemePath = [[NSString alloc] initWithFormat:@"%@/%@",SCHEMES_DIRECTORY(),schemeName];
    NSDictionary *schemeDictionary = [[NSDictionary alloc] initWithContentsOfFile:schemePath];
    [schemePath release];
    NSArray *basicArray = [schemeDictionary objectForKey:@"basic"];
    NSArray *gamemodArray = [schemeDictionary objectForKey:@"gamemod"];
    int result = 0;
    int i = 0;

    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00000001;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00000010;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00000004;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00000008;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00000020;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00000040;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00000080;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00000100;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00000200;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00000400;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00000800;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00002000;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00004000;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00008000;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00010000;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00020000;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00080000;
    if ([[gamemodArray objectAtIndex:i++] boolValue])
        result |= 0x00100000;  

    NSString *flags = [[NSString alloc] initWithFormat:@"e$gmflags %d",result];
    [self sendToEngine:flags];
    [flags release];

    i = 0;
    NSString *dmgMod = [[NSString alloc] initWithFormat:@"e$damagepct %d",[[basicArray objectAtIndex:i++] intValue]];
    [self sendToEngine:dmgMod];
    [dmgMod release];

    NSString *turnTime = [[NSString alloc] initWithFormat:@"e$turntime %d",[[basicArray objectAtIndex:i++] intValue] * 1000];
    [self sendToEngine:turnTime];
    [turnTime release];

    result = [[basicArray objectAtIndex:i++] intValue]; // initial health

    NSString *sdTime = [[NSString alloc] initWithFormat:@"e$sd_turns %d",[[basicArray objectAtIndex:i++] intValue]];
    [self sendToEngine:sdTime];
    [sdTime release];

    NSString *crateDrops = [[NSString alloc] initWithFormat:@"e$casefreq %d",[[basicArray objectAtIndex:i++] intValue]];
    [self sendToEngine:crateDrops];
    [crateDrops release];

    NSString *minesTime = [[NSString alloc] initWithFormat:@"e$minestime %d",[[basicArray objectAtIndex:i++] intValue] * 1000];
    [self sendToEngine:minesTime];
    [minesTime release];

    NSString *minesNumber = [[NSString alloc] initWithFormat:@"e$landadds %d",[[basicArray objectAtIndex:i++] intValue]];
    [self sendToEngine:minesNumber];
    [minesNumber release];

    NSString *dudMines = [[NSString alloc] initWithFormat:@"e$minedudpct %d",[[basicArray objectAtIndex:i++] intValue]];
    [self sendToEngine:dudMines];
    [dudMines release];

    NSString *explosives = [[NSString alloc] initWithFormat:@"e$explosives %d",[[basicArray objectAtIndex:i++] intValue]];
    [self sendToEngine:explosives];
    [explosives release];

    [schemeDictionary release];
    return result;
}

#pragma mark -
#pragma mark Thread/Network relevant code
// select one of GameSetup method and execute it in a seprate thread
-(void) startThread: (NSString *) selector {
    SEL usage = NSSelectorFromString(selector);
    [NSThread detachNewThreadSelector:usage toTarget:self withObject:nil];
}

// wrapper that computes the length of the message and then sends the command string, saving the command on a file
-(int) sendToEngine: (NSString *)string {
    uint8_t length = [string length];

    [[NSString stringWithFormat:@"%c%@",length,string] appendToFile:savePath];
    SDLNet_TCP_Send(csd, &length, 1);
    return SDLNet_TCP_Send(csd, [string UTF8String], length);
}

// wrapper that computes the length of the message and then sends the command string, skipping file writing
-(int) sendToEngineNoSave: (NSString *)string {
    uint8_t length = [string length];

    SDLNet_TCP_Send(csd, &length, 1);
    return SDLNet_TCP_Send(csd, [string UTF8String], length);
}

// method that handles net setup with engine and keeps connection alive
-(void) engineProtocol {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    TCPsocket sd;
    IPaddress ip;
    int eProto;
    BOOL clientQuit;
    uint8_t buffer[BUFFER_SIZE];
    uint8_t msgSize;

    clientQuit = NO;
    csd = NULL;

    if (SDLNet_Init() < 0) {
        DLog(@"SDLNet_Init: %s", SDLNet_GetError());
        clientQuit = YES;
    }

    // Resolving the host using NULL make network interface to listen
    if (SDLNet_ResolveHost(&ip, NULL, ipcPort) < 0 && !clientQuit) {
        DLog(@"SDLNet_ResolveHost: %s\n", SDLNet_GetError());
        clientQuit = YES;
    }

    // Open a connection with the IP provided (listen on the host's port)
    if (!(sd = SDLNet_TCP_Open(&ip)) && !clientQuit) {
        DLog(@"SDLNet_TCP_Open: %s %\n", SDLNet_GetError(), ipcPort);
        clientQuit = YES;
    }

    DLog(@"Waiting for a client on port %d", ipcPort);
    while (csd == NULL)
        csd = SDLNet_TCP_Accept(sd);
    SDLNet_TCP_Close(sd);

    while (!clientQuit) {
        NSString *msgToSave = nil;
        NSOutputStream *os = nil;
        msgSize = 0;
        memset(buffer, '\0', BUFFER_SIZE);
        if (SDLNet_TCP_Recv(csd, &msgSize, sizeof(uint8_t)) <= 0)
            break;
        if (SDLNet_TCP_Recv(csd, buffer, msgSize) <=0)
            break;

        switch (buffer[0]) {
            case 'C':
                DLog(@"sending game config...\n%@",self.gameConfig);

                if (isNetGame == YES)
                    [self sendToEngineNoSave:@"TN"];
                else
                    [self sendToEngineNoSave:@"TL"];
                NSString *saveHeader = @"TS";
                [[NSString stringWithFormat:@"%c%@",[saveHeader length], saveHeader] appendToFile:savePath];

                // seed info
                [self sendToEngine:[self.gameConfig objectForKey:@"seed_command"]];

                // dimension of the map
                [self sendToEngine:[self.gameConfig objectForKey:@"templatefilter_command"]];
                [self sendToEngine:[self.gameConfig objectForKey:@"mapgen_command"]];
                [self sendToEngine:[self.gameConfig objectForKey:@"mazesize_command"]];

                // static land (if set)
                NSString *staticMap = [self.gameConfig objectForKey:@"staticmap_command"];
                if ([staticMap length] != 0)
                    [self sendToEngine:staticMap];

                // lua script (if set)
                NSString *script = [self.gameConfig objectForKey:@"mission_command"];
                if ([script length] != 0)
                    [self sendToEngine:script];
                
                // theme info
                [self sendToEngine:[self.gameConfig objectForKey:@"theme_command"]];

                // scheme (returns initial health)
                NSInteger health = [self provideScheme:[self.gameConfig objectForKey:@"scheme"]];

                NSArray *teamsConfig = [self.gameConfig objectForKey:@"teams_list"];
                for (NSDictionary *teamData in teamsConfig) {
                    [self provideTeamData:[teamData objectForKey:@"team"]
                                  forHogs:[[teamData objectForKey:@"number"] intValue]
                               withHealth:health
                                  ofColor:[teamData objectForKey:@"color"]];
                }

                [self provideAmmoData:[self.gameConfig objectForKey:@"weapon"] forPlayingTeams:[teamsConfig count]];
                break;
            case '?':
                DLog(@"Ping? Pong!");
                [self sendToEngine:@"!"];
                break;
            case 'E':
                DLog(@"ERROR - last console line: [%s]", &buffer[1]);
                clientQuit = YES;
                break;
            case 'e':
                msgToSave = [NSString stringWithFormat:@"%c%s",msgSize,buffer];                
                [msgToSave appendToFile:self.savePath];
                
                sscanf((char *)buffer, "%*s %d", &eProto);
                short int netProto = 0;
                char *versionStr;

                HW_versionInfo(&netProto, &versionStr);
                if (netProto == eProto) {
                    DLog(@"Setting protocol version %d (%s)", eProto, versionStr);
                } else {
                    DLog(@"ERROR - wrong protocol number: [%s] - expecting %d", &buffer[1], eProto);
                    clientQuit = YES;
                }
                break;
            case 'i':
                switch (buffer[1]) {
                    case 'r':
                        DLog(@"Winning team: %s", &buffer[2]);
                        break;
                    case 'k':
                        DLog(@"Best Hedgehog: %s", &buffer[2]);
                        break;
                    default:
                        // TODO: losta stats stuff
                        break;
                }
                break;
            case 'q':
                // game ended, can remove the savefile
                [[NSFileManager defaultManager] removeItemAtPath:self.savePath error:nil];
                // so update the relative viewcontroler
                [[NSNotificationCenter defaultCenter] postNotificationName:@"removedSave" object:nil];
                // and disable the overlay
                setGameRunning(NO);
                break;
            default:
                // is it performant to reopen the stream every time? 
                os = [[NSOutputStream alloc] initToFileAtPath:self.savePath append:YES];
                [os open];
                [os write:&msgSize maxLength:1];
                [os write:buffer maxLength:msgSize];
                [os close];
                [os release];
                break;
        }
    }
    DLog(@"Engine exited, closing server");
    // wait a little to let the client close cleanly
    [NSThread sleepForTimeInterval:2];
    // Close the client socket
    SDLNet_TCP_Close(csd);
    SDLNet_Quit();

    [pool release];
    //Invoking this method should be avoided as it does not give your thread a chance to clean up any resources it allocated during its execution.
    //[NSThread exit];
}

#pragma mark -
#pragma mark Setting methods
// returns an array of c-strings that are read by engine at startup
-(const char **)getSettings: (NSString *)recordFile {
    NSString *ipcString = [[NSString alloc] initWithFormat:@"%d", ipcPort];
    NSString *localeString = [[NSString alloc] initWithFormat:@"%@.txt", [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    NSString *wSize = [[NSString alloc] initWithFormat:@"%d", (int) screenBounds.size.width];
    NSString *hSize = [[NSString alloc] initWithFormat:@"%d", (int) screenBounds.size.height];
    const char **gameArgs = (const char**) malloc(sizeof(char *) * 10);
    NSInteger tmpQuality;

    NSString *modelId = modelType();
    if ([modelId hasPrefix:@"iPhone1"] ||                                   // = iPhone or iPhone 3G
        [modelId hasPrefix:@"iPod1,1"] || [modelId hasPrefix:@"iPod2,1"])   // = iPod Touch or iPod Touch 2G
        tmpQuality = 0x00000001 | 0x00000002 | 0x00000040;  // rqLowRes | rqBlurryLand | rqKillFlakes
    else if ([modelId hasPrefix:@"iPhone2"] ||                              // = iPhone 3GS
             [modelId hasPrefix:@"iPod3"])                                  // = iPod Touch 3G
            tmpQuality = 0x00000002 | 0x00000040;           // rqBlurryLand | rqKillFlakes
        else if ([modelId hasPrefix:@"iPad1"])                              // = iPad
                tmpQuality = 0x00000002;                    // rqBlurryLand
            else                                                            // = everything else
                tmpQuality = 0;                             // full quality
    if (![modelId hasPrefix:@"iPad"])                                       // = disable tooltips unless iPad
        tmpQuality = tmpQuality | 0x00000400;

    // prevents using an empty nickname
    NSString *username;
    NSString *originalUsername = [self.systemSettings objectForKey:@"username"];
    if ([originalUsername length] == 0)
        username = [[NSString alloc] initWithFormat:@"MobileUser-%@",ipcString];
    else
        username = [[NSString alloc] initWithString:originalUsername];

    gameArgs[ 0] = [ipcString UTF8String];                                                       //ipcPort
    gameArgs[ 1] = [wSize UTF8String];                                                           //cScreenHeight
    gameArgs[ 2] = [hSize UTF8String];                                                           //cScreenWidth
    gameArgs[ 3] = [[[NSNumber numberWithInteger:tmpQuality] stringValue] UTF8String];           //quality
    gameArgs[ 4] = "en.txt";//[localeString UTF8String];                                                    //cLocaleFName
    gameArgs[ 5] = [username UTF8String];                                                        //UserNick
    gameArgs[ 6] = [[[self.systemSettings objectForKey:@"sound"] stringValue] UTF8String];       //isSoundEnabled
    gameArgs[ 7] = [[[self.systemSettings objectForKey:@"music"] stringValue] UTF8String];       //isMusicEnabled
    gameArgs[ 8] = [[[self.systemSettings objectForKey:@"alternate"] stringValue] UTF8String];   //cAltDamage
    gameArgs[ 9] = NULL;                                                                         //unused
    gameArgs[10] = [recordFile UTF8String];                                                      //recordFileName

    [wSize release];
    [hSize release];
    [localeString release];
    [ipcString release];
    [username release];
    return gameArgs;
}


@end
