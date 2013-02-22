/*
 * Hedgewars, a free turn based strategy game
 * Copyright (c) 2004-2012 Andrey Korotaev <unC0Rr@gmail.com>
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

#ifndef THEMEPROMPT_H
#define THEMEPROMPT_H

#include <QWidget>
#include <QDialog>
#include <QListView>

class QLineEdit;
class QModelIndex;
class QSortFilterProxyModel;
class LineEditCursor;

class ThemeListView : public QListView
{
    friend class ThemePrompt;

    public:
        ThemeListView(QWidget* parent = 0) : QListView(parent){}
};

class ThemePrompt : public QDialog
{
        Q_OBJECT

    public:
        ThemePrompt(int currentIndex = 0, QWidget* parent = 0);

    private:
        LineEditCursor * txtFilter;
        ThemeListView * list;
        QSortFilterProxyModel * filterModel;

    private slots:
        void onAccepted();
        void themeChosen(const QModelIndex & index);
        void filterChanged(const QString & text);
        void moveUp();
        void moveDown();
        void moveLeft();
        void moveRight();
};

#endif // THEMEPROMPT_H
