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

#ifndef LINEEDITCURSOR_H
#define LINEEDITCURSOR_H

#include <QLineEdit>

class LineEditCursor : public QLineEdit
{
        Q_OBJECT

    public:
        LineEditCursor(QWidget* parent = 0) : QLineEdit(parent) {}

    signals:
        void moveUp();
        void moveDown();
        void moveLeft();
        void moveRight();

    private:
        void keyPressEvent(QKeyEvent * event);
};

#endif // LINEEDITCURSOR_H
