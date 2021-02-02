function [tabel_full_filename, table, table2] = save_Table4(images, table_points, table_points2, startFrame, endFrame, count, table_save_folder, image_save_folder, table_save_file, rote)

%save, cornerTypeName, minQuality, filterName, MaxBidirectionalError, BlockSize)
mac = isunix;
table = table_points;
table2 = table_points2;
info_table = cell(3,1);

switch count
    case 1
        tabel_full_filename = [table_save_folder table_save_file '.xlsx'];
        
        if mac == 1
        else
            xlswrite(tabel_full_filename,table, 2);
            if ~isempty(table2)
                xlswrite(tabel_full_filename,table2, 3);
            end
        end
        %         save([table_save_folder table_save_file '-all.mat'],'table');
        %         save([table_save_folder table_save_file '-valid.mat'],'table2');
        
        info_table{1,1} = image_save_folder;
        info_table{2,1} = num2str(startFrame);
        info_table{3,1} = num2str(endFrame);
        info_table{4,1} = num2str(rote);
        
        info_table = cell2table(info_table);
        info_table = table2array(info_table);
        
        if mac == 1
        else
            xlswrite(tabel_full_filename,info_table, 1);
        end
        %         save([table_save_folder table_save_file '-info.mat'],'info_table');
        if ~isempty(table2)
            mac_table = struct('info',info_table,'all',table,'zeroed',table2);
        else
            mac_table = struct('info',info_table,'all',table);
        end
        save([table_save_folder table_save_file '.mat'],'mac_table');
        
        %{
    case 2
        tabel_full_filename = [table_save_folder 'valid_tracked-' table_save_file '.xlsx']
        xlswrite(tabel_full_filename,table, 2);
        
        info_table{1,1} = image_save_folder;
        info_table{2,1} = num2str(startFrame);
        info_table{2,2} = 'removed';
        info_table{3,1} = num2str(endFrame);
        info_table{4,1} = num2str(rote);

        info_table = cell2table(info_table);
        info_table = table2array(info_table);
        
        xlswrite(tabel_full_filename,info_table, 1);
        
    case 3
        writetable(csvTable, [save 'grid_points.csv']);
        %}
end
