/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2005-2012 Andrey Korotaev <unC0Rr@gmail.com>
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
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
 */

char sdlkeys[1024][2][128] =
{
    {"mousel", QT_TRANSLATE_NOOP("binds (keys)", "Mouse: Left button")},
    {"mousem", QT_TRANSLATE_NOOP("binds (keys)", "Mouse: Middle button")},
    {"mouser", QT_TRANSLATE_NOOP("binds (keys)", "Mouse: Right button")},
    {"wheelup", QT_TRANSLATE_NOOP("binds (keys)", "Mouse: Wheel up")},
    {"wheeldown", QT_TRANSLATE_NOOP("binds (keys)", "Mouse: Wheel down")},
    {"backspace", QT_TRANSLATE_NOOP("binds (keys)", "Backspace")},
    {"tab", QT_TRANSLATE_NOOP("binds (keys)", "Tab")},
    {"clear", QT_TRANSLATE_NOOP("binds (keys)", "Clear")},
    {"return", QT_TRANSLATE_NOOP("binds (keys)", "Return")},
    {"pause", QT_TRANSLATE_NOOP("binds (keys)", "Pause")},
    {"escape", QT_TRANSLATE_NOOP("binds (keys)", "Escape")},
    {"space", QT_TRANSLATE_NOOP("binds (keys)", "Space")},
    {"!", "!"},
    {"\"", "\""},
    {"#", "#"},
    {"$", "$"},
    {"&", "&"},
    {"'", "'"},
    {"(", "("},
    {")", ")"},
    {"*", "*"},
    {"+", "+"},
    {",", ","},
    {"-", "-"},
    {".", "."},
    {"/", "/"},
    {"0", "0"},
    {"1", "1"},
    {"2", "2"},
    {"3", "3"},
    {"4", "4"},
    {"5", "5"},
    {"6", "6"},
    {"7", "7"},
    {"8", "8"},
    {"9", "9"},
    {":", ":"},
    {";", ";"},
    {"<", "<"},
    {"=", "="},
    {">", ">"},
    {"?", "?"},
    {"@", "@"},
    {"[", "["},
    {"\\", "\\"},
    {"]", "]"},
    {"^", "^"},
    {"_", "_"},
    {"`", "`"},
    {"a", "A"},
    {"b", "B"},
    {"c", "C"},
    {"d", "D"},
    {"e", "E"},
    {"f", "F"},
    {"g", "G"},
    {"h", "H"},
    {"i", "I"},
    {"j", "J"},
    {"k", "K"},
    {"l", "L"},
    {"m", "M"},
    {"n", "N"},
    {"o", "O"},
    {"p", "P"},
    {"q", "Q"},
    {"r", "R"},
    {"s", "S"},
    {"t", "T"},
    {"u", "U"},
    {"v", "V"},
    {"w", "W"},
    {"x", "X"},
    {"y", "Y"},
    {"z", "Z"},
    {"delete", QT_TRANSLATE_NOOP("binds (keys)", "Delete")},
    {"[0]", QT_TRANSLATE_NOOP("binds (keys)", "Numpad 0")},
    {"[1]", QT_TRANSLATE_NOOP("binds (keys)", "Numpad 1")},
    {"[2]", QT_TRANSLATE_NOOP("binds (keys)", "Numpad 2")},
    {"[3]", QT_TRANSLATE_NOOP("binds (keys)", "Numpad 3")},
    {"[4]", QT_TRANSLATE_NOOP("binds (keys)", "Numpad 4")},
    {"[5]", QT_TRANSLATE_NOOP("binds (keys)", "Numpad 5")},
    {"[6]", QT_TRANSLATE_NOOP("binds (keys)", "Numpad 6")},
    {"[7]", QT_TRANSLATE_NOOP("binds (keys)", "Numpad 7")},
    {"[8]", QT_TRANSLATE_NOOP("binds (keys)", "Numpad 8")},
    {"[9]", QT_TRANSLATE_NOOP("binds (keys)", "Numpad 9")},
    {"[.]", QT_TRANSLATE_NOOP("binds (keys)", "Numpad .")},
    {"[/]", QT_TRANSLATE_NOOP("binds (keys)", "Numpad /")},
    {"[*]", QT_TRANSLATE_NOOP("binds (keys)", "Numpad *")},
    {"[-]", QT_TRANSLATE_NOOP("binds (keys)", "Numpad -")},
    {"[+]", QT_TRANSLATE_NOOP("binds (keys)", "Numpad +")},
    {"enter", QT_TRANSLATE_NOOP("binds (keys)", "Enter")},
    {"equals", QT_TRANSLATE_NOOP("binds (keys)", "Equals")},
    {"up", QT_TRANSLATE_NOOP("binds (keys)", "Up")},
    {"down", QT_TRANSLATE_NOOP("binds (keys)", "Down")},
    {"right", QT_TRANSLATE_NOOP("binds (keys)", "Right")},
    {"left", QT_TRANSLATE_NOOP("binds (keys)", "Left")},
    {"insert", QT_TRANSLATE_NOOP("binds (keys)", "Insert")},
    {"home", QT_TRANSLATE_NOOP("binds (keys)", "Home")},
    {"end", QT_TRANSLATE_NOOP("binds (keys)", "End")},
    {"page up", QT_TRANSLATE_NOOP("binds (keys)", "Page up")},
    {"page down", QT_TRANSLATE_NOOP("binds (keys)", "Page down")},
    {"f1", "F1"},
    {"f2", "F2"},
    {"f3", "F3"},
    {"f4", "F4"},
    {"f5", "F5"},
    {"f6", "F6"},
    {"f7", "F7"},
    {"f8", "F8"},
    {"f9", "F9"},
    {"f10", "F10"},
    {"f11", "F11"},
    {"f12", "F12"},
    {"f13", "F13"},
    {"f14", "F14"},
    {"f15", "F15"},
    {"numlock", QT_TRANSLATE_NOOP("binds (keys)", "Num lock")},
    {"caps_lock", QT_TRANSLATE_NOOP("binds (keys)", "Caps lock")},
    {"scroll_lock", QT_TRANSLATE_NOOP("binds (keys)", "Scroll lock")},
    {"right_shift", QT_TRANSLATE_NOOP("binds (keys)", "Right shift")},
    {"left_shift", QT_TRANSLATE_NOOP("binds (keys)", "Left shift")},
    {"right_ctrl", QT_TRANSLATE_NOOP("binds (keys)", "Right ctrl")},
    {"left_ctrl", QT_TRANSLATE_NOOP("binds (keys)", "Left ctrl")},
    {"right_alt", QT_TRANSLATE_NOOP("binds (keys)", "Right alt")},
    {"left_alt", QT_TRANSLATE_NOOP("binds (keys)", "Left alt")},
    {"right_meta", QT_TRANSLATE_NOOP("binds (keys)", "Right meta")},
    {"left_meta", QT_TRANSLATE_NOOP("binds (keys)", "Left meta")}
};

// button name definitions for Microsoft's XBox360 controller
// don't modify button order!
char xb360buttons[][128] =
{
    QT_TRANSLATE_NOOP("binds (keys)", "A button"),
    QT_TRANSLATE_NOOP("binds (keys)", "B button"),
    QT_TRANSLATE_NOOP("binds (keys)", "X button"),
    QT_TRANSLATE_NOOP("binds (keys)", "Y button"),
    QT_TRANSLATE_NOOP("binds (keys)", "LB button"),
    QT_TRANSLATE_NOOP("binds (keys)", "RB button"),
    QT_TRANSLATE_NOOP("binds (keys)", "Back button"),
    QT_TRANSLATE_NOOP("binds (keys)", "Start button"),
    QT_TRANSLATE_NOOP("binds (keys)", "Left stick"),
    QT_TRANSLATE_NOOP("binds (keys)", "Right stick")
};

// axis name definitions for Microsoft's XBox360 controller
// don't modify axis order!
char xbox360axes[][128] =
{
    QT_TRANSLATE_NOOP("binds (keys)", "Left stick (Right)"),
    QT_TRANSLATE_NOOP("binds (keys)", "Left stick (Left)"),
    QT_TRANSLATE_NOOP("binds (keys)", "Left stick (Down)"),
    QT_TRANSLATE_NOOP("binds (keys)", "Left stick (Up)"),
    QT_TRANSLATE_NOOP("binds (keys)", "Left trigger"),
    QT_TRANSLATE_NOOP("binds (keys)", "Right trigger"),
    QT_TRANSLATE_NOOP("binds (keys)", "Right stick (Down)"),
    QT_TRANSLATE_NOOP("binds (keys)", "Right stick (Up)"),
    QT_TRANSLATE_NOOP("binds (keys)", "Right stick (Right)"),
    QT_TRANSLATE_NOOP("binds (keys)", "Right stick (Left)"),
};
char xb360dpad[128] = QT_TRANSLATE_NOOP("binds (keys)", "DPad");
