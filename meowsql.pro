QT += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = meowsql
TEMPLATE = app

greaterThan(QT_MINOR_VERSION, 4) { # >= 5.5
    CONFIG  += c++14
} else {
    CONFIG  += c++11
}

CONFIG += WITH_MYSQL
CONFIG += WITH_POSTGRESQL
CONFIG += WITH_SQLITE
CONFIG += WITH_QTSQL
#CONFIG += WITH_LIBSSH

#CONFIG += WITH_LIBMYSQL_SOURCES #tried to experiment with WASM

WITH_QTSQL {
    QT += sql
} else {
    # sqlite is made on Qt SQL module
    CONFIG -= WITH_SQLITE
}

WITH_MYSQL {
    DEFINES += WITH_MYSQL
}

WITH_POSTGRESQL {
    DEFINES += WITH_POSTGRESQL
}

WITH_SQLITE {
    DEFINES += WITH_SQLITE
}

WITH_QTSQL {
    DEFINES += WITH_QTSQL
}

WITH_LIBSSH {
    DEFINES += WITH_LIBSSH
}

# below doesn't work on win with old Qt
unix:CONFIG += object_parallel_to_source
unix:OBJECTS_DIR = .

QMAKE_LFLAGS += -Wl,--no-as-needed # ?
macx:QMAKE_LFLAGS -= -Wl,--no-as-needed
macx:QMAKE_LFLAGS += -Wl

# (mysql_config --libs)
unix:LIBS += -lpthread # pthread
unix:LIBS += -lrt
unix:LIBS += -lz # zlib - compression/decompression library
unix:LIBS += -lm # math?
unix:LIBS += -ldl # dynamic link
macx:LIBS -= -lrt

win32:LIBS += -lUser32 #SetProcessDPIAware()
win32:LIBS += -lws2_32 # WSAStartup() - sockets

# MySQL
WITH_MYSQL {
    !WITH_LIBMYSQL_SOURCES:unix:LIBS += -lmysqlclient # mysql client
    win32:LIBS += -l"$$PWD\third_party\libmysql\windows\libmysql"
    macx:LIBS += -L/usr/local/opt/mysql-connector-c/lib
}

# PostgreSQL
WITH_POSTGRESQL {
    unix:LIBS += -lpq # pkg-config --libs libpq
    win32:LIBS += -l"$$PWD\third_party\libpq\windows\lib\libpq"
}

DEFINES += YY_NO_UNISTD_H # fix flex compilation on win

SOURCES += main.cpp\
    app/actions.cpp \
    app/app.cpp \
    app/log.cpp \
    db/connection.cpp \
    db/connection_parameters.cpp \
    db/connection_features.cpp \
    db/connection_params_manager.cpp \
    db/connections_manager.cpp \
    db/connection_query_killer.cpp \
    db/database_editor.cpp \
    db/data_type/data_type.cpp \
    db/entity/database_entity.cpp \
    db/entity/entities_fetcher.cpp \
    db/entity/entity.cpp \
    db/entity/entity_filter.cpp \
    db/entity/entity_holder.cpp \
    db/entity/entity_factory.cpp \
    db/entity/routine_entity.cpp \
    db/entity/session_entity.cpp \
    db/entity/table_entity_comparator.cpp \
    db/entity/table_entity.cpp \
    db/entity/trigger_entity.cpp \
    db/entity/view_entity.cpp \
    db/exception.cpp \
    db/foreign_key.cpp \
    db/native_query_result.cpp \
    db/query.cpp \
    db/query_criteria.cpp \
    db/query_data.cpp \
    db/query_data_fetcher.cpp \
    db/routine_editor.cpp \
    db/routine_structure_parser.cpp \
    db/routine_structure.cpp \
    db/session_variables.cpp \
    db/table_column.cpp \
    db/table_editor.cpp \
    db/table_index.cpp \
    db/table_structure.cpp \
    db/table_structure_parser.cpp \
    db/db_thread_initializer.cpp \
    db/trigger_editor.cpp \
    db/trigger_structure_parser.cpp \
    db/trigger_structure.cpp \
    db/view_editor.cpp \
    db/view_structure.cpp \
    db/view_structure_parser.cpp \
    db/user_queries_manager.cpp \
    db/user_query/batch_executor.cpp \
    db/user_query/sentences_parser.cpp \
    db/user_query/user_query.cpp \
    helpers/formatting.cpp \
    helpers/logger.cpp \
    helpers/parsing.cpp \
    helpers/random_password_generator.cpp \
    helpers/text.cpp \
    settings/settings_core.cpp \
    settings/settings_geometry.cpp \
    settings/settings_icons.cpp \
    settings/settings_text.cpp \
    settings/data_editors.cpp \
    settings/queries_storage.cpp \
    settings/query_data_export_storage.cpp \
    settings/table_filters_storage.cpp \
    ssh/openssh_tunnel.cpp \
    ssh/ssh_tunnel_factory.cpp \
    ssh/ssh_tunnel_parameters.cpp \
    threads/db_thread.cpp \
    threads/queries_task.cpp \
    threads/thread_init_task.cpp \
    threads/thread_task.cpp \
    ui/common/checkbox_list_popup.cpp \
    ui/common/data_type_combo_box.cpp \
    ui/common/geometry_helpers.cpp \
    ui/common/sql_editor.cpp \
    ui/common/sql_log_editor.cpp \
    ui/common/sql_syntax_highlighter.cpp \
    ui/common/table_column_default_editor.cpp \
    ui/common/table_cell_line_edit.cpp \
    ui/common/table_view.cpp \
    ui/common/text_editor_popup.cpp \
    ui/delegates/checkbox_delegate.cpp \
    ui/delegates/checkbox_list_item_editor_wrapper.cpp \
    ui/delegates/combobox_delegate.cpp \
    ui/delegates/combobox_item_editor_wrapper.cpp \
    ui/delegates/edit_query_data_delegate.cpp \
    ui/delegates/line_edit_item_editor_wrapper.cpp \
    ui/delegates/date_time_item_editor_wrapper.cpp \
    ui/delegates/foreign_key_columns_delegate.cpp \
    ui/delegates/foreign_key_foreign_columns_delegate.cpp \
    ui/delegates/foreign_key_reference_option_delegate.cpp \
    ui/delegates/foreign_key_reference_table_delegate.cpp \
    ui/delegates/table_column_collation_delegate.cpp \
    ui/delegates/table_column_default_delegate.cpp \
    ui/delegates/table_column_type_delegate.cpp \
    ui/delegates/table_index_delegate.cpp \
    ui/edit_database/dialog.cpp \
    ui/export_database/bottom_widget.cpp \
    ui/export_database/top_widget.cpp \
    ui/export_query/options_widget.cpp \
    ui/export_query/output_format_widget.cpp \
    ui/export_query/output_target_widget.cpp \
    ui/export_query/export_query_data_dialog.cpp \
    ui/export_query/row_selection_widget.cpp \
    ui/main_window/central_left_db_tree.cpp \
    ui/main_window/central_left_widget.cpp \
    ui/main_window/central_right/database/central_right_database_tab.cpp \
    ui/main_window/central_right/data/central_right_data_tab.cpp \
    ui/main_window/central_right/data/cr_data_filter_widget.cpp \
    ui/main_window/central_right/global_filter_widget.cpp \
    ui/main_window/central_right/host/central_right_host_tab.cpp \
    ui/main_window/central_right/host/cr_host_databases_tab.cpp \
    ui/main_window/central_right/host/cr_host_variables_tab.cpp \
    ui/main_window/central_right/query/central_right_query_tab.cpp \
    ui/main_window/central_right/query/cr_query_data_tab.cpp \
    ui/main_window/central_right/query/cr_query_panel.cpp \
    ui/main_window/central_right/query/cr_query_result.cpp \
    ui/main_window/central_right/table/central_right_table_tab.cpp \
    ui/main_window/central_right/table/cr_table_columns.cpp \
    ui/main_window/central_right/table/cr_table_columns_tools.cpp \
    ui/main_window/central_right/table/cr_table_foreign_keys_tools.cpp \
    ui/main_window/central_right/table/cr_table_indexes_tools.cpp \
    ui/main_window/central_right/table/cr_table_info_basic_tab.cpp \
    ui/main_window/central_right/table/cr_table_info.cpp \
    ui/main_window/central_right/table/cr_table_info_foreign_keys_tab.cpp \
    ui/main_window/central_right/table/cr_table_info_indexes_tab.cpp \
    ui/main_window/central_right/table/cr_table_info_options_tab.cpp \
    ui/main_window/central_right/trigger/central_right_trigger_tab.cpp \
    ui/main_window/central_right/trigger/cr_trigger_body.cpp \
    ui/main_window/central_right/trigger/cr_trigger_options.cpp \
    ui/main_window/central_right/view/central_right_view_tab.cpp \
    ui/main_window/central_right/routine/central_right_routine_tab.cpp \
    ui/main_window/central_right/routine/cr_routine_body.cpp \
    ui/main_window/central_right/routine/cr_routine_info.cpp \
    ui/main_window/central_right/routine/cr_routine_info_options_tab.cpp \
    ui/main_window/central_right/routine/cr_routine_info_parameters_tab.cpp \
    ui/main_window/central_right/routine/cr_routine_parameters_tools.cpp \
    ui/main_window/central_right_widget.cpp \
    ui/main_window/central_widget.cpp \
    ui/main_window/main_window.cpp \
    ui/main_window/main_window_status_bar.cpp \
    ui/models/base_data_table_model.cpp \
    ui/models/connection_params_model.cpp \
    ui/models/database_entities_table_model.cpp \
    ui/models/databases_table_model.cpp \
    ui/models/data_table_model.cpp \
    ui/models/entities_tree_model.cpp \
    ui/models/entities_tree_sort_filter_proxy_model.cpp \
    ui/models/query_data_sort_filter_proxy_model.cpp \
    ui/models/table_columns_model.cpp \
    ui/models/table_foreign_keys_model.cpp \
    ui/models/table_indexes_model.cpp \
    ui/models/table_indexes_model_item.cpp \
    ui/models/routine_parameters_model.cpp \
    ui/models/users_table_model.cpp \
    ui/models/user_privileges_model.cpp \
    ui/models/variables_table_model.cpp \
    ui/models/session_objects_tree_model.cpp \
    ui/presenters/central_right_host_widget_model.cpp \
    ui/presenters/central_right_widget_model.cpp \
    ui/presenters/table_info_widget_model.cpp \
    ui/presenters/routine_info_widget_model.cpp \
    ui/presenters/central_right_data_filter_form.cpp \
    ui/presenters/central_right_query_presenter.cpp \
    ui/presenters/connection_parameters_form.cpp \
    ui/presenters/edit_database_form.cpp \
    ui/presenters/editable_data_context_menu_presenter.cpp \
    ui/presenters/export_database_form.cpp \
    ui/presenters/export_query_presenter.cpp \
    ui/presenters/routine_form.cpp \
    ui/presenters/select_db_object_form.cpp \
    ui/presenters/table_info_form.cpp \
    ui/presenters/trigger_form.cpp \
    ui/presenters/text_editor_popup_form.cpp \
    ui/presenters/view_form.cpp \
    ui/presenters/user_management_form.cpp \
    ui/user_manager/user_manager_window.cpp \
    ui/user_manager/left_widget.cpp \
    ui/user_manager/right_widget.cpp \
    ui/user_manager/options_widget.cpp \
    ui/user_manager/privileges_widget.cpp \
    ui/user_manager/credentials_tab.cpp \
    ui/user_manager/limitations_tab.cpp \
    ui/user_manager/select_db_object.cpp \
    ui/session_manager/session_form.cpp \
    ui/session_manager/settings_tab.cpp \
    ui/session_manager/ssh_tunnel_tab.cpp \
    ui/session_manager/start_tab.cpp \
    ui/session_manager/window.cpp \
    db/editable_grid_data.cpp \
    db/query_data_editor.cpp \
    ui/common/editable_query_data_table_view.cpp \
    ui/main_window/central_bottom_widget.cpp \
    ui/main_window/central_log_widget.cpp \
    utils/exporting/mysql_dump_console.cpp \
    utils/exporting/query_data_exporter.cpp \
    utils/exporting/query_data_export_formats/format.cpp \
    utils/exporting/query_data_export_formats/format_factory.cpp \
    ui/export_database/export_dialog.cpp


HEADERS  +=  app/actions.h \
    app/app.h \
    app/log.h \
    db/collation_fetcher.h \
    db/common.h \
    db/connection.h \
    db/connection_parameters.h \
    db/connection_features.h \
    db/connection_params_manager.h \
    db/connections_manager.h \
    db/connection_query_killer.h \
    db/database_editor.h \
    db/data_type/connection_data_types.h \
    db/data_type/data_type_category.h \
    db/data_type/data_type.h \
    db/entity/database_entity.h \
    db/entity/entities_fetcher.h \
    db/entity/entity_filter.h \
    db/entity/entity.h \
    db/entity/entity_holder.h \
    db/entity/entity_factory.h \
    db/entity/routine_entity.h \
    db/entity/session_entity.h \
    db/entity/table_entity_comparator.h \
    db/entity/table_entity.h \
    db/entity/trigger_entity.h \
    db/entity/view_entity.h \
    db/exception.h \
    db/foreign_key.h \
    db/native_query_result.h \
    db/query_column.h \
    db/query_criteria.h \
    db/query_data_fetcher.h \
    db/routine_editor.h \
    db/routine_structure_parser.h \
    db/routine_structure.h \
    db/session_variables.h \
    db/query_data.h \
    db/query_results.h \
    db/query.h \
    db/table_column.h \
    db/table_editor.h \
    db/table_engines_fetcher.h \
    db/table_index.h \
    db/table_structure.h \
    db/table_structure_parser.h \
    db/db_thread_initializer.h \
    db/trigger_editor.h \
    db/trigger_structure_parser.h \
    db/trigger_structure.h \
    db/view_editor.h \
    db/view_structure.h \
    db/view_structure_parser.h \
    db/user_manager.h \
    db/user_editor_interface.h \
    db/user_query/batch_executor.h \
    db/user_query/sentences_parser.h \
    db/user_query/user_query.h \
    db/user_queries_manager.h \
    helpers/formatting.h \
    helpers/logger.h \
    helpers/parsing.h \
    helpers/random_password_generator.h \
    helpers/text.h \
    settings/settings_core.h \
    settings/settings_geometry.h \
    settings/settings_icons.h \
    settings/settings_text.h \
    settings/data_editors.h \
    settings/queries_storage.h \
    settings/query_data_export_storage.h \
    settings/table_filters_storage.h \
    ssh/openssh_tunnel.h \
    ssh/ssh_tunnel_factory.h \
    ssh/ssh_tunnel_parameters.h \
    threads/helpers.h \
    threads/mutex.h \
    threads/db_thread.h \
    threads/queries_task.h \
    threads/thread_init_task.h \
    threads/thread_task.h \
    ui/common/checkbox_list_popup.h \
    ui/common/data_type_combo_box.h \
    ui/common/geometry_helpers.h \
    ui/common/mysql_syntax.h \
    ui/common/sql_editor.h \
    ui/common/sql_log_editor.h \
    ui/common/sql_syntax_highlighter.h \
    ui/common/table_column_default_editor.h \
    ui/common/table_cell_line_edit.h \
    ui/common/table_view.h \
    ui/common/text_editor_popup.h \
    ui/delegates/checkbox_delegate.h \
    ui/delegates/checkbox_list_item_editor_wrapper.h \
    ui/delegates/combobox_delegate.h \
    ui/delegates/combobox_item_editor_wrapper.h \
    ui/delegates/edit_query_data_delegate.h \
    ui/delegates/line_edit_item_editor_wrapper.h \
    ui/delegates/date_time_item_editor_wrapper.h \
    ui/delegates/foreign_key_columns_delegate.h \
    ui/delegates/foreign_key_foreign_columns_delegate.h \
    ui/delegates/foreign_key_reference_option_delegate.h \
    ui/delegates/foreign_key_reference_table_delegate.h \
    ui/delegates/table_column_collation_delegate.h \
    ui/delegates/table_column_default_delegate.h \
    ui/delegates/table_column_type_delegate.h \
    ui/delegates/table_index_delegate.h \
    ui/edit_database/dialog.h \
    ui/export_database/bottom_widget.h \
    ui/export_database/top_widget.h \
    ui/export_query/options_widget.h \
    ui/export_query/output_format_widget.h \
    ui/export_query/output_target_widget.h \
    ui/export_query/export_query_data_dialog.h \
    ui/export_query/row_selection_widget.h \
    ui/main_window/central_left_db_tree.h \
    ui/main_window/central_left_widget.h \
    ui/main_window/central_right/base_root_tab.h \
    ui/main_window/central_right/database/central_right_database_tab.h \
    ui/main_window/central_right/data/central_right_data_tab.h \
    ui/main_window/central_right/data/cr_data_filter_widget.h \
    ui/main_window/central_right/global_filter_widget.h \
    ui/main_window/central_right/global_data_filter_interface.h \
    ui/main_window/central_right/host/central_right_host_tab.h \
    ui/main_window/central_right/host/cr_host_databases_tab.h \
    ui/main_window/central_right/host/cr_host_variables_tab.h \
    ui/main_window/central_right/query/central_right_query_tab.h \
    ui/main_window/central_right/query/cr_query_data_tab.h \
    ui/main_window/central_right/query/cr_query_panel.h \
    ui/main_window/central_right/query/cr_query_result.h \
    ui/main_window/central_right/table/central_right_table_tab.h \
    ui/main_window/central_right/table/cr_table_columns.h \
    ui/main_window/central_right/table/cr_table_columns_tools.h \
    ui/main_window/central_right/table/cr_table_foreign_keys_tools.h \
    ui/main_window/central_right/table/cr_table_indexes_tools.h \
    ui/main_window/central_right/table/cr_table_info_basic_tab.h \
    ui/main_window/central_right/table/cr_table_info_foreign_keys_tab.h \
    ui/main_window/central_right/table/cr_table_info.h \
    ui/main_window/central_right/table/cr_table_info_indexes_tab.h \
    ui/main_window/central_right/table/cr_table_info_options_tab.h \
    ui/main_window/central_right/trigger/central_right_trigger_tab.h \
    ui/main_window/central_right/trigger/cr_trigger_body.h \
    ui/main_window/central_right/trigger/cr_trigger_options.h \
    ui/main_window/central_right/view/central_right_view_tab.h \
    ui/main_window/central_right/routine/central_right_routine_tab.h \
    ui/main_window/central_right/routine/cr_routine_body.h \
    ui/main_window/central_right/routine/cr_routine_info.h \
    ui/main_window/central_right/routine/cr_routine_info_options_tab.h \
    ui/main_window/central_right/routine/cr_routine_info_parameters_tab.h \
    ui/main_window/central_right/routine/cr_routine_parameters_tools.h \
    ui/main_window/central_right_widget.h \
    ui/main_window/central_widget.h \
    ui/main_window/main_window.h \
    ui/main_window/main_window_status_bar.h \
    ui/models/base_data_table_model.h \
    ui/models/connection_params_model.h \
    ui/models/database_entities_table_model.h \
    ui/models/databases_table_model.h \
    ui/models/data_table_model.h \
    ui/models/entities_tree_model.h \
    ui/models/entities_tree_sort_filter_proxy_model.h \
    ui/models/query_data_sort_filter_proxy_model.h \
    ui/models/table_columns_model.h \
    ui/models/table_foreign_keys_model.h \
    ui/models/table_indexes_model.h \
    ui/models/table_indexes_model_item.h \
    ui/models/routine_parameters_model.h \
    ui/models/users_table_model.h \
    ui/models/user_privileges_model.h \
    ui/models/variables_table_model.h \
    ui/models/session_objects_tree_model.h \
    ui/presenters/central_right_host_widget_model.h \
    ui/presenters/central_right_widget_model.h \
    ui/presenters/central_right_data_filter_form.h \
    ui/presenters/table_info_widget_model.h \
    ui/presenters/routine_info_widget_model.h \
    ui/presenters/central_right_query_presenter.h \
    ui/presenters/connection_parameters_form.h \
    ui/presenters/edit_database_form.h \
    ui/presenters/editable_data_context_menu_presenter.h \
    ui/presenters/export_database_form.h \
    ui/presenters/export_query_presenter.h \
    ui/presenters/routine_form.h \
    ui/presenters/select_db_object_form.h \
    ui/presenters/table_info_form.h \
    ui/presenters/trigger_form.h \
    ui/presenters/text_editor_popup_form.h \
    ui/presenters/view_form.h \
    ui/presenters/user_management_form.h \
    ui/user_manager/user_manager_window.h \
    ui/user_manager/left_widget.h \
    ui/user_manager/right_widget.h \
    ui/user_manager/options_widget.h \
    ui/user_manager/privileges_widget.h \
    ui/user_manager/credentials_tab.h \
    ui/user_manager/limitations_tab.h \
    ui/user_manager/select_db_object.h \
    ui/session_manager/session_form.h \
    ui/session_manager/settings_tab.h \
    ui/session_manager/ssh_tunnel_tab.h \
    ui/session_manager/start_tab.h \
    ui/session_manager/window.h \
    db/editable_grid_data.h \
    db/query_data_editor.h \
    ui/common/editable_query_data_table_view.h \
    ui/main_window/central_bottom_widget.h \
    ui/main_window/central_log_widget.h \
    utils/exporting/mysql_dump_console.h \
    utils/exporting/query_data_exporter.h \
    utils/exporting/query_data_export_formats/format.h \
    utils/exporting/query_data_export_formats/format_csv.h \
    utils/exporting/query_data_export_formats/format_factory.h \
    utils/exporting/query_data_export_formats/format_html_table.h \
    utils/exporting/query_data_export_formats/format_json.h \
    utils/exporting/query_data_export_formats/format_latex.h \
    utils/exporting/query_data_export_formats/format_markdown.h \
    utils/exporting/query_data_export_formats/format_php_array.h \
    utils/exporting/query_data_export_formats/format_sql.h \
    utils/exporting/query_data_export_formats/format_sql_deletes_replaces.h \
    utils/exporting/query_data_export_formats/format_sql_inserts.h \
    utils/exporting/query_data_export_formats/format_sql_replaces.h \
    utils/exporting/query_data_export_formats/format_wiki.h \
    utils/exporting/query_data_export_formats/format_xml.h \
    ui/export_database/export_dialog.h

win32:SOURCES += ssh/plink_ssh_tunnel.cpp
win32:HEADERS += ssh/plink_ssh_tunnel.h

WITH_MYSQL {
    SOURCES += db/data_type/mysql_connection_data_types.cpp \
    db/entity/mysql_entity_filter.cpp \
    db/mysql/mysql_database_editor.cpp \
    db/mysql/mysql_entities_fetcher.cpp \
    db/mysql/mysql_query_result.cpp \
    db/mysql/mysql_query_data_editor.cpp \
    db/mysql/mysql_collation_fetcher.cpp \
    db/mysql/mysql_connection.cpp \
    db/mysql/mysql_connection_query_killer.cpp \
    db/mysql/mysql_query_data_fetcher.cpp \
    db/mysql/mysql_table_editor.cpp \
    db/mysql/mysql_table_engines_fetcher.cpp \
    db/mysql/mysql_user_manager.cpp \
    db/mysql/mysql_user_editor.cpp \
    db/mysql/mysql_library_initializer.cpp \
    db/mysql/mysql_thread_initializer.cpp \
}

WITH_POSTGRESQL {
    SOURCES += db/data_type/pg_connection_data_types.cpp \
    db/pg/pg_connection.cpp \
    db/pg/pg_connection_query_killer.cpp \
    db/pg/pg_entities_fetcher.cpp \
    db/pg/pg_entity_create_code_generator.cpp \
    db/pg/pg_query_result.cpp \
    db/pg/pg_query_data_editor.cpp \
    db/pg/pg_query_data_fetcher.cpp
}

WITH_SQLITE {
    SOURCES += db/data_type/sqlite_connection_datatypes.cpp \
    db/sqlite/sqlite_connection.cpp \
    db/sqlite/sqlite_entities_fetcher.cpp \
    db/sqlite/sqlite_table_structure_parser.cpp \
    utils/sql_parser/sqlite/sqlite_parser.cpp \
    utils/sql_parser/sqlite/sqlite_bison_parser.cpp \
    utils/sql_parser/sqlite/sqlite_flex_lexer.cpp \
    utils/sql_parser/sqlite/sqlite_types.cpp \
}

WITH_QTSQL {
    SOURCES += db/qtsql/qtsql_query_result.cpp
}

WITH_MYSQL {
    HEADERS += db/data_type/mysql_data_type.h \
    db/mysql/mysql_query_result.h \
    db/data_type/mysql_connection_data_types.h \
    db/entity/mysql_entity_filter.h \
    db/mysql/mysql_database_editor.h \
    db/mysql/mysql_entities_fetcher.h \
    db/mysql/mysql_query_result.h \
    db/mysql/mysql_query_data_editor.h \
    db/mysql/mysql_collation_fetcher.h \
    db/mysql/mysql_connection.h \
    db/mysql/mysql_connection_query_killer.h \
    db/mysql/mysql_query_data_fetcher.h \
    db/mysql/mysql_table_editor.h \
    db/mysql/mysql_table_engines_fetcher.h \
    db/mysql/mysql_user_manager.h \
    db/mysql/mysql_user_editor.h \
    db/mysql/mysql_library_initializer.h \
    db/mysql/mysql_thread_initializer.h
}

WITH_POSTGRESQL {
    HEADERS += db/data_type/pg_connection_data_types.h \
    db/data_type/pg_data_type.h \
    db/pg/pg_query_result.h \
    db/pg/pg_connection.h \
    db/pg/pg_connection_query_killer.h \
    db/pg/pg_entities_fetcher.h \
    db/pg/pg_entity_create_code_generator.h \
    db/pg/pg_query_data_editor.h \
    db/pg/pg_query_data_fetcher.h
}

WITH_SQLITE {
    HEADERS += db/data_type/sqlite_connection_datatypes.cpp \
    db/sqlite/sqlite_connection.h \
    db/sqlite/sqlite_entities_fetcher.h \
    db/sqlite/sqlite_table_structure_parser.h \
    utils/sql_parser/sqlite/sqlite_parser.h \
    utils/sql_parser/sqlite/sqlite_bison_parser.hpp \
    utils/sql_parser/sqlite/sqlite_flex_lexer.h \
    utils/sql_parser/sqlite/sqlite_types.h
}

WITH_QTSQL {
    HEADERS += db/qtsql/qtsql_query_result.h
}

WITH_MYSQL {
    win32:INCLUDEPATH += "$$PWD\third_party\libmysql\windows\include"
    !WITH_LIBMYSQL_SOURCES:unix:INCLUDEPATH += /usr/include/mysql
    macx:INCLUDEPATH += /usr/local/include/mysql
}

WITH_POSTGRESQL {
    win32:INCLUDEPATH += "$$PWD\third_party\libpq\windows\include\postgresql"
    unix:INCLUDEPATH += /usr/include/postgresql # pkg-config --cflags libpq
    macx:INCLUDEPATH += /usr/local/include
}

WITH_LIBSSH {
    LIBS += -lssh

    HEADERS += ssh/sockets/connection.h \
    ssh/sockets/socket.h \
    ssh/sockets/connection_receiver_interface.h \
    ssh/sockets/socket_receiver_interface.h \
    ssh/libssh.h \
    ssh/libssh_channel.h \
    ssh/libssh_tunnel.h \
    ssh/libssh_connection.h

    SOURCES += ssh/sockets/connection.cpp \
    ssh/sockets/socket.cpp \
    ssh/libssh.cpp \
    ssh/libssh_channel.cpp \
    ssh/libssh_tunnel.cpp \
    ssh/libssh_connection.cpp
}

WITH_LIBMYSQL_SOURCES { # TODO: rm

    DEFINES += HAVE_OPENSSL
    DEFINES += PTHREAD_ADAPTIVE_MUTEX_INITIALIZER_NP

    LIBS += -lssl
    LIBS += -lcrypto

    INCLUDEPATH += third_party/libmysql/source/src/mysql-5.7.30/include
    INCLUDEPATH += third_party/libmysql/source/src/mysql-5.7.30/libmysql
    INCLUDEPATH += third_party/libmysql/source/src/mysql-5.7.30/regex
    INCLUDEPATH += third_party/libmysql/source/src/mysql-5.7.30/sql
    INCLUDEPATH += third_party/libmysql/source/src/mysql-5.7.30/strings
    INCLUDEPATH += third_party/libmysql/source/src/mysql-5.7.30/mysys
    INCLUDEPATH += third_party/libmysql/source/src/mysql-5.7.30/zlib

    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/libmysql/libmysql.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/libmysql/errmsg.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/sql-common/client.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/sql-common/client_plugin.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/sql-common/client_authentication.cc
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/sql-common/pack.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/sql-common/my_time.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/sql/net_serv.cc
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/sql/auth/password.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/sql/auth/sha2_password_common.cc

    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/array.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/charset-def.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/charset.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/checksum.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/errors.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/hash.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/list.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_cache.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_dirname.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_fn_ext.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_format.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_getdate.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_iocache.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_iocache2.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_keycache.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_keycaches.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_loadpath.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_pack.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_path.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_qsort.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_radix.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_same.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_soundex.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_arr_appstr.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_tempfile.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_unixpath.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mf_wcomp.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/mulalloc.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_access.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_alloc.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_bit.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_bitmap.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_chsize.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_compress.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_copy.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_create.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_delete.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_div.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_error.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_file.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_fopen.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_fstream.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_gethwaddr.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_getsystime.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_getwd.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_compare.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_init.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_lib.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_lock.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_malloc.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_mess.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_mkdir.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_mmap.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_once.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_open.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_pread.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_read.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_redel.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_rename.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_seek.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_static.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_symlink.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_symlink2.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_sync.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_thr_init.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_write.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/ptr_cmp.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/queues.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/sql_chars.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/stacktrace.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/string.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/thr_cond.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/thr_lock.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/thr_mutex.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/thr_rwlock.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/tree.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/typelib.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/base64.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_memmem.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/lf_alloc-pin.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/lf_dynarray.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/lf_hash.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_rdtsc.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/psi_noop.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_syslog.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_chmod.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_thread.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_crc32.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys/my_largepage.c

    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/zlib/crc32.c

    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/dbug/dbug.c

    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/vio/vio.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/vio/viosocket.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/vio/viossl.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/vio/viosslfactories.c

    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/bchange.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-big5.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-bin.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-cp932.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-czech.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-euc_kr.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-eucjpms.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-extra.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-gb2312.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-gbk.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-gb18030.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-latin1.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-mb.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-simple.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-sjis.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-tis620.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-uca.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-ucs2.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-ujis.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-utf8.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype-win1250ch.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/ctype.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/decimal.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/dtoa.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/int2str.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/is_prefix.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/llstr.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/longlong2str.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/my_strtoll10.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/my_vsnprintf.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/str2int.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/str_alloc.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/strcend.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/strend.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/strfill.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/strmake.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/my_stpmov.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/my_stpnmov.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/strxmov.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/strxnmov.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/xml.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/my_strchr.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/strcont.c
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/strings/strappend.c

    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys_ssl/crypt_genhash_impl.cc
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys_ssl/mf_tempdir.cc
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys_ssl/my_default.cc
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys_ssl/my_getopt.cc
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys_ssl/my_aes.cc
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys_ssl/my_sha1.cc
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys_ssl/my_md5.cc
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys_ssl/my_rnd.cc
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys_ssl/my_murmur3.cc
    SOURCES += third_party/libmysql/source/src/mysql-5.7.30/mysys_ssl/my_aes_openssl.cc

}

TRANSLATIONS += \
    resources/translations/meowsql_bg.ts \ # Bulgarian
    resources/translations/meowsql_zh.ts \ # Chinese
    resources/translations/meowsql_cs.ts \ # Czech
    resources/translations/meowsql_fr.ts \ # French
    resources/translations/meowsql_de.ts \ # German
    resources/translations/meowsql_hu.ts \ # Hungarian
    resources/translations/meowsql_it.ts \ # Italian
    resources/translations/meowsql_ko.ts \ # Korean
    resources/translations/meowsql_pt.ts \ # Portuguese
    resources/translations/meowsql_ro.ts \ # Romanian
    resources/translations/meowsql_ru.ts \ # Russian
    resources/translations/meowsql_es.ts \ # Spanish
    resources/translations/meowsql_sv.ts   # Swedish

RESOURCES += \
    icons.qrc \
    translations.qrc

win32:RC_ICONS += meowsqlico.ico
