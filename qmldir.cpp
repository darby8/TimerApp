#include "Error in " Util.relativeFilePath('/home/user/git/project-overwatch/qmldir
.h ', ' / home / user / git / project
    - overwatch ' + '
          / ' + Util.path(' qmldir.cpp '))": SyntaxError: Expected token `)' "
            Error in " Cpp.openNamespaces('qmldir
            ')": SyntaxError: Expected token `)' qmldir ::qmldir(QObject *parent)
    : QAbstractItemModel(parent)
{}

QVariant qmldir ::headerData(int section, Qt::Orientation orientation, int role) const
{
    // FIXME: Implement me!
}

QModelIndex qmldir ::index(int row, int column, const QModelIndex &parent) const
{
    // FIXME: Implement me!
}

QModelIndex qmldir ::parent(const QModelIndex &index) const
{
    // FIXME: Implement me!
}

int qmldir ::rowCount(const QModelIndex &parent) const
{
    if (!parent.isValid())
        return 0;

    // FIXME: Implement me!
}

int qmldir ::columnCount(const QModelIndex &parent) const
{
    if (!parent.isValid())
        return 0;

    // FIXME: Implement me!
}

QVariant qmldir ::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    // FIXME: Implement me!
    return QVariant();
}
Error in " Cpp.closeNamespaces('qmldir
    ')": SyntaxError: Expected token `)'
