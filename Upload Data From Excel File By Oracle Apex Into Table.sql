/* Formatted on 27/07/2023 10:59:33 AM (QP5 v5.326) */
DECLARE
    CURSOR C2 IS
        SELECT C001,
               C002,
               C003,
               C004,
               C005
          FROM APEX_COLLECTIONS
         WHERE COLLECTION_NAME = 'COLLECTION_NAME';
BEGIN
    EXECUTE IMMEDIATE 'TRUNCATE TABLE Table_Name';

    IF APEX_COLLECTION.COLLECTION_EXISTS ('COLLECTION_NAME')
    THEN
        APEX_COLLECTION.TRUNCATE_COLLECTION ('COLLECTION_NAME');
    END IF;

    IF NOT APEX_COLLECTION.COLLECTION_EXISTS ('COLLECTION_NAME')
    THEN
        APEX_COLLECTION.CREATE_COLLECTION ('COLLECTION_NAME');
    END IF;



    FOR r1 IN (SELECT *
                 FROM apex_application_temp_files  f,
                      TABLE (apex_data_parser.parse (
                                 p_content           => f.blob_content,
                                 p_add_headers_row   => 'Y',
                                 -- p_store_profile_to_collection => 'FILE_PROV_CASH',

                                 p_file_name         => f.filename,
                                 p_skip_rows         => 1)) p
                WHERE f.name = :P1_UPLOAD)
    LOOP
        APEX_COLLECTION.ADD_MEMBER (
            P_COLLECTION_NAME   => 'COLLECTION_NAME',
            p_c001              => NVL (REPLACE (r1.col001, '-', ''), 0),
            p_c002              => NVL (REPLACE (r1.col002, '-', ''), 0),
            P_C003              => NVL (REPLACE (r1.col003, '-', ''), 0),
            p_c004              => NVL (REPLACE (r1.col004, '-', ''), 0),
            p_c005              => NVL (REPLACE (r1.col005, '-', ''), 0));
    END LOOP;

    FOR I IN C2
    LOOP
        INSERT INTO Table_Name (Column_name,                --All table column
                                Column_name,
                                Column_name,
                                Column_name,
                                Column_name)
             VALUES (I.C001,                                 --collection data
                     I.C002,
                     I.C003,
                     I.C004,
                     I.C005);
    END LOOP;

    COMMIT;
END;
