function [tabel_full_filename, table] = save_Table_analyze(table_points, table_save_folder, table_save_file)

mac = isunix;
table = table_points;
tabel_full_filename = [table_save_folder table_save_file '.xlsx'];

if mac == 1
    mac_table = struct('all',table);
    save([table_save_folder table_save_file '.mat'],'mac_table');
else
    xlswrite(tabel_full_filename,table, 1);
end

end
