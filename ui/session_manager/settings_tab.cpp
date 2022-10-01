#include "ui/session_manager/settings_tab.h"

namespace meow {
namespace ui {
namespace session_manager {

SettingsTab::SettingsTab(QWidget * parent) : QWidget(parent)
{

    _mainGridLayout = new QGridLayout();
    int row = 0;

    // Network type ------------------------------------------------------------
    _networkTypeLabel = new QLabel(tr("Network type:"));
    _mainGridLayout->addWidget(_networkTypeLabel, row, 0);
    _networkTypeComboBox = new QComboBox();
    _networkTypeLabel->setBuddy(_networkTypeComboBox);
    _networkTypeComboBox->insertItems(0, meow::db::networkTypeNames());
    _mainGridLayout->addWidget(_networkTypeComboBox, row, 1);
    connect(_networkTypeComboBox,
            static_cast<void(QComboBox::*)(int)>(&QComboBox::currentIndexChanged),
            [=](int index) {
                if (_form) {
                    QVector<db::NetworkType> networkTypes
                            = meow::db::networkTypes();
                    _form->setNetworkType(networkTypes[index]);
                    _compressionCheckBox->setEnabled(
                        _form->supportsCompressionOption());
                }
            });
    row++;

    // Hostname / IP -----------------------------------------------------------
    _hostLabel = new QLabel(tr("Hostname / IP:"));
    _mainGridLayout->addWidget(_hostLabel, row, 0);
    _hostEdit = new QLineEdit();
    _hostLabel->setBuddy(_hostEdit);
    _mainGridLayout->addWidget(_hostEdit, row, 1);
    connect(_hostEdit, &QLineEdit::textEdited,
            [=](const QString &newHost) {
                if (_form) {
                    _form->setHostName(newHost);
                }
            });
    row++;

    // Filename ----------------------------------------------------------------

    _filenameLabel = new QLabel(tr("Filename:"));
    _mainGridLayout->addWidget(_filenameLabel, row, 0);

    QHBoxLayout * filenameLayout = new QHBoxLayout();

    _filenameEdit = new QLineEdit;
    _filenameLabel->setBuddy(_filenameEdit);
    connect(_filenameEdit, &QLineEdit::textEdited,
            [=](const QString &newName) {
                if (_form) {
                    _form->setFileName(newName);
                }
            });

    _filenameSelectionButton = new QPushButton(
                QIcon(":/icons/folder_explore.png"),
                tr(""));
    connect(_filenameSelectionButton,
            &QAbstractButton::clicked,
            this,
            &SettingsTab::onFilenameSelectionButtonClicked
    );
    _filenameSelectionButton->setMinimumWidth(30);

    filenameLayout->addWidget(_filenameEdit, 20);
    filenameLayout->addWidget(_filenameSelectionButton, 1);

    _mainGridLayout->addLayout(filenameLayout, row, 1);

    row++;

    // Prompt for credentials --------------------------------------------------
    /*_loginPromptCheckBox = new QCheckBox(tr("Prompt for credentials"));
    _mainGridLayout->addWidget(_loginPromptCheckBox, row, 1);
    connect(_loginPromptCheckBox, &QCheckBox::stateChanged,
            [=](int newState) {
                onLoginPromptUpdate();
                if (_form) {
                    _form->setLoginPrompt(newState == Qt::Checked);
                }
            });
    row++;*/ // hide as not finished

    // User --------------------------------------------------------------------
    _userLabel = new QLabel(tr("User:"));
    _mainGridLayout->addWidget(_userLabel, row, 0);
    _userEdit = new QLineEdit();
    _userLabel->setBuddy(_userEdit);
    _mainGridLayout->addWidget(_userEdit, row, 1);
    connect(_userEdit, &QLineEdit::textEdited,
            [=](const QString &newUser) {
                if (_form) {
                    _form->setUserName(newUser);
                }
            });
    row++;

    // Password ----------------------------------------------------------------
    _passwordLabel = new QLabel(tr("Password:"));
    _mainGridLayout->addWidget(_passwordLabel, row, 0);
    _passwordEdit = new QLineEdit();
    _passwordEdit->setEchoMode(QLineEdit::Password);
    _passwordLabel->setBuddy(_passwordEdit);
    _mainGridLayout->addWidget(_passwordEdit, row, 1);
    connect(_passwordEdit, &QLineEdit::textEdited,
            [=](const QString &newPassword) {
                if (_form) {
                    _form->setPassword(newPassword);
                }
            });
    row++;

    // Port --------------------------------------------------------------------
    _portLabel = new QLabel(tr("Port:"));
    _mainGridLayout->addWidget(_portLabel, row, 0);
    _portSpinBox = new QSpinBox();
    _portSpinBox->setMinimum(0);
    _portSpinBox->setMaximum(65535);
    _portSpinBox->resize(70, _portSpinBox->height());
    _portLabel->setBuddy(_portSpinBox);
    QHBoxLayout * spinBoxLayout = new QHBoxLayout();
    spinBoxLayout->addWidget(_portSpinBox);
    spinBoxLayout->addStretch(1);
    _mainGridLayout->addLayout(spinBoxLayout, row, 1);
    connect(_portSpinBox,
            static_cast<void(QSpinBox::*)(int)>(&QSpinBox::valueChanged),
            [=](int newPort){
                if (_form) {
                    _form->setPort(static_cast<quint16>(newPort));
                }
            });
    row++;

    // Compression -------------------------------------------------------------
    _compressionCheckBox
            = new QCheckBox(tr("Compressed client/server protocol"));
    connect(_compressionCheckBox, &QCheckBox::stateChanged,
            [=](int newState) {
                if (_form) {
                    _form->setCompressed(newState == Qt::Checked);
                }
            });
    _mainGridLayout->addWidget(_compressionCheckBox, row, 1);

    row++;


    // Databases ---------------------------------------------------------------
    _databasesLabel = new QLabel(tr("Databases:"));
    _mainGridLayout->addWidget(_databasesLabel, row, 0);
    _databasesEdit = new QLineEdit();
    _databasesEdit->setToolTip(tr("Separated by semicolon"));
    _databasesEdit->setPlaceholderText(tr("All"));
    QAction * showListAction = _databasesEdit->addAction(
                QIcon(":/icons/dropdown_highlight.png"),
                QLineEdit::TrailingPosition);
    connect(showListAction, &QAction::triggered,
            this, &SettingsTab::onShowDatabaseListAction);

    _databasesLabel->setBuddy(_databasesEdit);
    _mainGridLayout->addWidget(_databasesEdit, row, 1);
    connect(_databasesEdit, &QLineEdit::textChanged,
            [=](const QString &newDatabaseList) {
                if (_form) {
                    _form->setDatabases(newDatabaseList);
                }
            });
    row++;

    _mainGridLayout->setColumnMinimumWidth(0, 150);
    _mainGridLayout->setColumnStretch(1, 2);
    _mainGridLayout->setAlignment(Qt::AlignTop);
    this->setLayout(_mainGridLayout);

    onLoginPromptUpdate();
}

void SettingsTab::setForm(presenters::ConnectionParametersForm * form)
{
    _form = form;
    fillDataFromForm();
    onLoginPromptUpdate();
}

void SettingsTab::fillDataFromForm()
{
    if (!_form) {
        return;
    }

    QVector<db::NetworkType> networkTypes = meow::db::networkTypes();
    _networkTypeComboBox->setCurrentIndex(
            networkTypes.indexOf(_form->networkType()));
    _hostEdit->setText(_form->hostName());
    _filenameEdit->setText(_form->fileName());
    //_loginPromptCheckBox->setChecked(_form->isLoginPrompt());
    _compressionCheckBox->setChecked(_form->isCompressed());
    _userEdit->setText(_form->userName());
    _passwordEdit->setText(_form->password());
    _databasesEdit->setText(_form->databases());
    _portSpinBox->setValue(_form->port());

    // host
    _hostLabel->setHidden(_form->isFilebased());
    _hostEdit->setHidden(_form->isFilebased());

    // file name
    _filenameLabel->setHidden(!_form->isFilebased());
    _filenameEdit->setHidden(!_form->isFilebased());
    _filenameSelectionButton->setHidden(!_form->isFilebased());

    // show/hide auth
    _userLabel->setHidden(!_form->supportsAuth());
    _userEdit->setHidden(!_form->supportsAuth());
    _passwordLabel->setHidden(!_form->supportsAuth());
    _passwordEdit->setHidden(!_form->supportsAuth());

    // no port when no network
    _portLabel->setHidden(_form->isFilebased());
    _portSpinBox->setHidden(_form->isFilebased());

    // database selection
    _databasesLabel->setHidden(!_form->supportsMultipleDatabases());
    _databasesEdit->setHidden(!_form->supportsMultipleDatabases());
}

void SettingsTab::onLoginPromptUpdate()
{
    return; // temp
    /*bool loginChecked = _loginPromptCheckBox->isChecked();
    _userEdit->setDisabled(loginChecked);
    _userLabel->setDisabled(loginChecked);
    _passwordEdit->setDisabled(loginChecked);
    _passwordLabel->setDisabled(loginChecked);*/
}

void SettingsTab::onShowDatabaseListAction()
{
    // listening: Dark Tranquillity - Focus Shift

    if (_form) {

        QApplication::setOverrideCursor(Qt::WaitCursor);

        QStringList allDatabases = _form->allDatabases();

        if (!allDatabases.isEmpty()) {

            // hate regexps, but better rm all whitespaces:
            QStringList enteredDatabases = _databasesEdit->text()
                .remove(' ')
                .split(db::databasesSeparator, QString::SkipEmptyParts);
            enteredDatabases.removeDuplicates();

            QMenu * listMenu = new QMenu;

            for (auto dbName : allDatabases) {
                QAction * nameAction = new QAction(dbName, listMenu);
                nameAction->setCheckable(true);
                nameAction->setChecked(enteredDatabases.contains(dbName));
                listMenu->addAction(nameAction);
            }

            int menuXPos = _databasesEdit->width() - listMenu->sizeHint().width();
            int menuYPos = _databasesEdit->height() - 1;

            QApplication::restoreOverrideCursor();

            QAction * executedAction
                    = listMenu->exec(_databasesEdit->mapToGlobal(
                                         QPoint(menuXPos, menuYPos)));

            if (executedAction) {

                QStringList checkedNames;

                for (auto action : listMenu->actions()) {
                    if (action->isChecked()) {
                        checkedNames.append(action->text());
                    }
                }
                _databasesEdit->setText(checkedNames.join(db::databasesSeparator));
            }

            delete listMenu;
        } else {
            QApplication::restoreOverrideCursor();
        }
    }

}

void SettingsTab::onFilenameSelectionButtonClicked()
{
    QFileDialog dialog(this);
    dialog.setFileMode(QFileDialog::AnyFile);
    dialog.selectFile(_form->fileName());
    //dialog.setNameFilter(tr("All files (*.*);;DB files (*.db)")); // TODO

    if (dialog.exec()) {
        QStringList fileNames = dialog.selectedFiles();
        if (fileNames.isEmpty() == false) {
            _form->setFileName(fileNames.first());
            _filenameEdit->setText(fileNames.first());
        }
    }
}

} // namespace session_manager
} // namespace ui
} // namespace meow
