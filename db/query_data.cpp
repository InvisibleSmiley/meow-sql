#include "query_data.h"
#include "helpers/formatting.h"
#include "query_data_editor.h"
#include "entity/table_entity.h"
#include "helpers/logger.h"
#include "app/app.h"

namespace meow {
namespace db {

QueryData::QueryData() : QObject(), _curRowNumber(-1), _resultIndex(0)
{

}

int QueryData::rowCount() const
{
    if (_queryPtr && _queryPtr->resultCount() > 0) {
        return static_cast<int>(currentResult()->recordCount());
    }
    return 0;
}

int QueryData::columnCount() const
{
    if (_queryPtr && _queryPtr->resultCount() > 0) {
        return static_cast<int>(currentResult()->columnCount());
    }
    return 0;
}

QString QueryData::columnName(int index) const
{
    if (_queryPtr) {
        return currentResult()->columnName(static_cast<std::size_t>(index));
    }
    return QString();
}

DataTypeCategoryIndex QueryData::columnDataTypeCategory(int index) const
{
    if (_queryPtr) {
        return currentResult()->column(index).dataType->categoryIndex;
    }
    return DataTypeCategoryIndex::Other;
}

db::DataTypePtr QueryData::dataTypeForColumn(int column) const
{
    if (_queryPtr) {
        return currentResult()->column(column).dataType;
    }
    return {};
}

bool QueryData::columnHasForeignKey(int column) const
{
    if (_queryPtr) {
        return !currentResult()->foreignKeysForColumn(column).isEmpty();
    }
    return false;
}

bool QueryData::columnIsAutoIncrement(int column) const
{
    if (_queryPtr) {
        return currentResult()->columnIsAutoIncrement(column);
    }
    return false;
}

bool QueryData::columnIsPrimaryKeyPart(std::size_t index) const
{
    if (_queryPtr) {
        return currentResult()->columnIsPrimaryKeyPart(index);
    }
    return false;
}

bool QueryData::columnIsUniqueKeyPart(std::size_t index) const
{
    if (_queryPtr) {
        return currentResult()->columnIsUniqueKeyPart(index);
    }
    return false;
}

bool QueryData::columnIsIndexKeyPart(std::size_t index) const
{
    if (_queryPtr) {
        return currentResult()->columnIsIndexKeyPart(index);
    }
    return false;
}

QString QueryData::displayDataAt(int row, int column) const
{
    currentResult()->seekRecNo(row);
    if (currentResult()->isNull(column)) {
        return "(NULL)"; // TODO: const
    } else {

        QString data = currentResult()->curRowColumn(column, true);

        // TODO: more formatting, see AnyGridGetText

        auto categoryIndex = columnDataTypeCategory(column);

        switch (categoryIndex) {

        case DataTypeCategoryIndex::Spatial:
        case DataTypeCategoryIndex::Binary:
            return helpers::formatAsHex(data);

        default:
            break;

        }


        return data;
    }
}

QVariant QueryData::editDataAt(int row, int column) const
{
    currentResult()->seekRecNo(row);

    if (currentResult()->entity()) {

        // Foreign Key
        if (meow::app()->settings()->dataEditors()
                ->enableDropDownForForeignKeyEditors()) {
            QList<ForeignKey *> fKeys
                    = currentResult()->foreignKeysForColumn(column);
            if (!fKeys.isEmpty()) {
                return editDataForForeignKey(fKeys.first(), columnName(column));
            }
        }

        auto categoryIndex = columnDataTypeCategory(column);

        switch (categoryIndex) {

        case DataTypeCategoryIndex::Other: {
            meow::db::DataTypePtr type = dataTypeForColumn(column);
            // Enum
            if (currentResult()->connection()->dataTypes()->isEnumType(type)
                   && meow::app()->settings()->dataEditors()
                        ->enableInplaceEnumEditor()) {
                return currentResult()->columnValuesList(column);

            // Set
            } else if (currentResult()->connection()->dataTypes()->isSetType(type)
                    && meow::app()->settings()->dataEditors()
                        ->enableInplaceSetEditor()) {
                return currentResult()->columnValuesList(column);

            }
        } break;

        default:
            break;

        }
    }

    if (currentResult()->isNull(column)) {
        return QString();
    } else {
        // TODO: format binary?

        return currentResult()->curRowColumn(column, true);
    }
}

bool QueryData::isNullAt(int row, int column) const
{
    currentResult()->seekRecNo(static_cast<std::size_t>(row));
    return currentResult()->isNull(static_cast<std::size_t>(column));
}

bool QueryData::setData(int row, int col, const QVariant &value)
{
    setCurrentRowNumber(row);
    prepareEditing();
    Q_ASSERT(currentResult()->editableData());
    currentResult()->editableData()->setData(row, col, value);

    return false;
}

void QueryData::prepareEditing()
{
    if (_queryPtr && _queryPtr->resultCount()) {
        currentResult()->prepareEditing();
        emit editingPrepared();
    }
}

bool QueryData::isModified() const
{
    return _queryPtr && _queryPtr->resultCount()
            && currentResult()->editableData()
            && currentResult()->editableData()->isModified();
}

bool QueryData::isInserted() const
{
    return _queryPtr && _queryPtr->resultCount()
            && currentResult()->editableData()
            && currentResult()->editableData()->isInserted();
}

int QueryData::modifiedRowNumber() const
{
    if (isModified()) {
        return currentResult()->editableData()->editableRow()->rowNumber;
    }
    return -1;
}

int QueryData::applyModifications()
{
    if (!isModified()) return -1;

    std::shared_ptr<QueryDataEditor> editor = currentResult()->connection()
                                                     ->queryDataEditor();

    if (editor->applyModificationsInDB(this)) {
        if (editor->loadModificationsResult()) {
            ensureFullRow(true); // load from db new values
        }
        return currentResult()->editableData()->applyModifications();
    }

    return -1;
}

int QueryData::discardModifications()
{
    if (!isModified()) return -1;

    return currentResult()->editableData()->discardModifications();
}

bool QueryData::deleteRowInDB(int row)
{
    // TODO: CheckEditable

    setCurrentRowNumber(row);
    prepareEditing();

    if (currentResult()->editableData()->isRowInserted(row) == false) {

        std::shared_ptr<QueryDataEditor> editor = currentResult()->connection()
                ->queryDataEditor();

        editor->deleteCurrentRow(this);
    }

    currentResult()->editableData()->deleteRow(row);

    return true;
}

void QueryData::deleteRow(int row)
{
    currentResult()->editableData()->deleteRow(row);
}

int QueryData::insertEmptyRow()
{
    if (!_queryPtr) {
        return -1;
    }
    prepareEditing();
    GridDataRow newRowData;
    for (int c = 0; c < columnCount(); ++c) {

        QString columnValue = QString(""); // empty, not NULL

        if (currentResult()->entity()
                && currentResult()->entity()->type() == Entity::Type::Table) {
            TableEntity * table = static_cast<TableEntity *>(currentResult()->entity());

            const auto & columns = table->structure()->columns();
            ColumnDefaultType columnDefaultType = columns[c]->defaultType();
            if (columnDefaultType == ColumnDefaultType::Null
                    || columnDefaultType == ColumnDefaultType::NullUpdateTS
                    || columnDefaultType == ColumnDefaultType::AutoInc) {
                columnValue = QString(); // (NULL)
            } else if (columnDefaultType == ColumnDefaultType::Text
                    || columnDefaultType == ColumnDefaultType::TextUpdateTS) {
                columnValue = currentResult()->connection()->unescapeString(
                    columns[c]->defaultText());
            }
        }

        newRowData << columnValue;
    }
    return currentResult()->editableData()
            ->insertRow(_curRowNumber + 1, newRowData);

}

int QueryData::duplicateCurrentRowWithoutKeys()
{
    if (!_queryPtr) {
        return -1;
    }
    if (_curRowNumber == -1) {
        return -1;
    }

    // Copy current row data, insert empty row and edit inserted raw data.
    // Need this trick to mark cells edited by user.

    GridDataRow sourceRowData = currentResult()->curRow();

    int newRowIndex = insertEmptyRow();

    QList<std::size_t> pkColumnIndices
            = currentResult()->primaryColumnIndices();

    std::size_t columnCount = static_cast<std::size_t>(sourceRowData.size());
    for (std::size_t col = 0; col < columnCount; ++col) {

        // TODO: exclude copying virtual columns

        QVariant value = sourceRowData.at(col);

        if (pkColumnIndices.contains(col)) {
            value = QString(); // (NULL)
        }

        currentResult()->editableData()->setData(newRowIndex, col, value);
    }
    return newRowIndex;
}

int QueryData::duplicateCurrentRowWithKeys()
{
    if (!_queryPtr) {
        return -1;
    }
    if (_curRowNumber == -1) {
        return -1;
    }
    // Copy current row data, insert empty row and edit inserted raw data.
    // Need this trick to mark cells edited by user.

    GridDataRow sourceRowData = currentResult()->curRow();

    int newRowIndex = insertEmptyRow();

    std::size_t columnCount = static_cast<std::size_t>(sourceRowData.size());
    for (std::size_t col = 0; col < columnCount; ++col) {

        // TODO: exclude copying virtual columns

        QVariant value = sourceRowData.at(col);

        currentResult()->editableData()->setData(newRowIndex, col, value);
    }
    return newRowIndex;
}

QString QueryData::whereForCurRow(bool beforeModifications) const
{
    QStringList whereList;

    QStringList keyColumns = currentResult()->keyColumns();

    bool useEditableData = false;
    std::size_t row = static_cast<std::size_t>(_curRowNumber);

    EditableGridData * editableData = currentResult()->editableData();
    if (editableData && editableData->editableRow()) {
        row = editableData->editableRow()->rowNumber;
        useEditableData = true;
    }

    std::size_t columnCount = currentResult()->columnCount();

    for (const QString & keyColumnName : keyColumns) {
        std::size_t i = static_cast<std::size_t>(-1);
        for (i = 0; i < columnCount; ++i) {
            if (keyColumnName == currentResult()->columnName(i)) {
                break;
            }
        }
        if (i == static_cast<std::size_t>(-1)) {
            throw db::Exception(
                QString("Cannot compose WHERE clause - column missing: %1")
                    .arg(keyColumnName));
        }
        QString whereName = currentResult()->connection()->quoteIdentifier(
            currentResult()->columnName(i)
        );

        QString value;

        if (useEditableData) {
            value = beforeModifications ?
                        editableData->notModifiedDataAt(row, i)
                      : editableData->dataAt(row, i);
        } else {
            currentResult()->seekRecNo(row);
            value = currentResult()->curRowColumn(i);
        }

        QString whereVal;

        if (value.isNull()) {
            whereVal = " IS NULL";
        } else {
            switch (currentResult()->column(i).dataType->categoryIndex) {
            case DataTypeCategoryIndex::Integer:
            case DataTypeCategoryIndex::Float:
                // TODO if bit
                whereVal = value.isEmpty() ? "0" : value;
                break;
            // TODO: other types
            default:
                whereVal = currentResult()->connection()->escapeString(value);
                break;
            }

            whereVal = '=' + whereVal;
        }

        whereList << whereName + whereVal;
    }

    return whereList.join(" AND ");
}

void QueryData::ensureFullRow(bool refresh)
{
    if (!refresh && hasFullData()) return;

    prepareEditing();

    EditableGridDataRow * row = currentResult()->editableData()->editableRow();
    Q_ASSERT(row != nullptr); // TODO create when not

    if (row->isInserted) {
        return; // TODO
    }

    QStringList columnNames = currentResult()->connection()->quoteIdentifiers(
        currentResult()->columnOrgNames()
    );

    Q_ASSERT(currentResult()->entity());

    QString entityName = db::quotedFullName(currentResult()->entity());
    QString selectSQL = QString("SELECT %1 FROM %2 WHERE %3 %4")
            .arg(columnNames.join(", "))
            .arg(entityName)
            .arg(whereForCurRow())
            .arg(currentResult()->connection()->limitOnePostfix(true));

    QStringList newRowData = currentResult()->connection()->getRow(selectSQL);
    if (newRowData.size() != row->data.size()) {
        meowLogC(Log::Category::Error) << "Failed to load full row";
        //Q_ASSERT(false);
        return;
    }

    row->data = newRowData;
}

void QueryData::setCurrentRowNumber(int row)
{
    _curRowNumber = row;
}

bool QueryData::hasFullData() const
{
    if (isModified()) return true;

    // TODO
    return true;
}

QVariant QueryData::editDataForForeignKey(ForeignKey * fKey,
                                          const QString & columnName) const
{
    QString textColumn;
    TableEntity * referenceTable = fKey->referenceTable();

    int columnIndex = fKey->columnNames().indexOf(columnName);

    if (columnIndex == -1) return QString();

    QString referenceKeyColumn = fKey->referenceColumns().at(columnIndex);

    for (TableColumn * column : referenceTable->structure()->columns()) {
        if (column->dataType()->categoryIndex
                == db::DataTypeCategoryIndex::Text
                && column->name() != referenceKeyColumn) {
            textColumn = column->name();
            break;
        }
    }

    QString SQL;

    referenceKeyColumn = currentResult()
            ->connection()->quoteIdentifier(referenceKeyColumn);

    if (textColumn.isEmpty()) {
        SQL = referenceKeyColumn + " FROM "
            + currentResult()->connection()->quoteIdentifier(
                referenceTable->name(), true, '.')
            + " GROUP BY " + referenceKeyColumn
            + " ORDER BY " + referenceKeyColumn;
    } else {
        QString quotedTextColumn
                = currentResult()->connection()->quoteIdentifier(textColumn);
        SQL = referenceKeyColumn + ", "
            + currentResult()->connection()->applyLeft(
                quotedTextColumn,
                meow::db::DATA_MAX_LOAD_TEXT_LEN)
            + " FROM "
            + currentResult()->connection()->quoteIdentifier(
                        referenceTable->name(), true, '.')
            + " GROUP BY " + referenceKeyColumn + ", " + quotedTextColumn
            + " ORDER BY " + quotedTextColumn;

    }

    SQL = currentResult()->connection()->applyQueryLimit("SELECT", SQL,
                                       meow::db::FOREIGN_MAX_ROWS);

    try {
        QueryPtr results = currentResult()->connection()->getResults(SQL);

        Query * queryPtr = results.get();

        if (textColumn.isEmpty()) {

            QStringList result;

            while (queryPtr->isEof() == false) {
                result.append(queryPtr->curRowColumn(0, true));
                queryPtr->seekNext();
            }

            return result;
        } else {
            // id => name
            IdValueList result;
            // Can't use QMap or QHash bc need to keep sort by name

            while (queryPtr->isEof() == false) {
                QString id = queryPtr->curRowColumn(0, true);
                QString name = queryPtr->curRowColumn(1, true);
                result.push_back({
                    id,              // key
                    id + ": " + name // value
                });
                queryPtr->seekNext();
            }

            QVariant variant;
            variant.setValue(result);

            return variant;
        }

    } catch (meow::db::Exception & ex) {
        Q_UNUSED(ex);
    }

    return QString();
}

} // namespace db
} // namespace meow
