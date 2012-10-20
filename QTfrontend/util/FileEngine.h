#ifndef _FileEngine_h
#define _FileEngine_h

#include <QAbstractFileEngine>
#include <QAbstractFileEngineHandler>
#include <QAbstractFileEngineIterator>
#include <QDateTime>

#include "physfs.h"



class FileEngine : public QAbstractFileEngine
{
    public:
        FileEngine(const QString& filename);

        virtual ~FileEngine();

        virtual bool open(QIODevice::OpenMode openMode);
        virtual bool close();
        virtual bool flush();
        virtual qint64 size() const;
        virtual qint64 pos() const;
        virtual bool seek(qint64 pos);
        virtual bool isSequential() const;
        virtual bool remove();
        virtual bool mkdir(const QString &dirName, bool createParentDirectories) const;
        virtual bool rmdir(const QString &dirName, bool recurseParentDirectories) const;
        virtual bool caseSensitive() const;
        virtual bool isRelativePath() const;
        QAbstractFileEngineIterator *beginEntryList(QDir::Filters filters, const QStringList & filterNames);
        virtual QStringList entryList(QDir::Filters filters, const QStringList &filterNames) const;
        virtual FileFlags fileFlags(FileFlags type=FileInfoAll) const;
        virtual QString fileName(FileName file=DefaultName) const;
        virtual QDateTime fileTime(FileTime time) const;
        virtual void setFileName(const QString &file);
        bool atEnd() const;

        virtual qint64 read(char *data, qint64 maxlen);
        virtual qint64 write(const char *data, qint64 len);

        bool isOpened() const;

        QFile::FileError error() const;
        QString errorString() const;

        virtual bool supportsExtension(Extension extension) const;

    private:
        PHYSFS_file *_handler;
        qint64 _size;
        FileFlags _flags;
        QString _filename;
        QDateTime _datetime;
};

class FileEngineHandler : public QAbstractFileEngineHandler
{
    public:
        FileEngineHandler(char * argv0);
        ~FileEngineHandler();

        QAbstractFileEngine *create(const QString &filename) const;

        void mount(const QString & path);
        void setWriteDir(const QString & path);

//    private:
        static const QString scheme;
};

class FileEngineIterator : public QAbstractFileEngineIterator
{
public:
        FileEngineIterator(QDir::Filters filters, const QStringList & nameFilters, const QStringList & entries);

        bool hasNext() const;
        QString next();
        QString currentFileName() const;
private:
        QStringList m_entries;
        int m_index;
};

#endif
