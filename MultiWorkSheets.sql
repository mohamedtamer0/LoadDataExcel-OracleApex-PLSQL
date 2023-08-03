/* Formatted on 03/08/2023 8:36:59 AM (QP5 v5.326) */
DECLARE
    CURSOR C2 IS
        SELECT C001,
               C002,
               C003,
               C004,
               C005
          FROM APEX_COLLECTIONS
         WHERE COLLECTION_NAME = 'COLLECTION_NAME';

    lss   VARCHAR2 (512);
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

    FOR x1 IN (SELECT sheet_file_name
                 FROM TABLE (apex_data_parser.get_xlsx_worksheets (
                                 p_content   =>
                                     (SELECT blob_content
                                        FROM apex_application_temp_files
                                       WHERE name = :P1_UPLOAD))) xp)
    LOOP
        lss := x1.sheet_file_name;

        -- INSERT INTO has_test (ITEM_CODE) values lss ;
        --end loop;


        FOR r1 IN (SELECT *
                     FROM apex_application_temp_files  f,
                          TABLE (apex_data_parser.parse (
                                     p_content           => f.blob_content,
                                     p_add_headers_row   => 'Y',
                                     -- p_store_profile_to_collection => 'FILE_PROV_CASH',
                                     p_xlsx_sheet_name   => lss,
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
    END LOOP;

    FOR I IN C2
    LOOP
        IF I.C001 <> '0' AND I.C002 <> '0'
        THEN
            INSERT INTO Table_Name (ASSEMBLY_ITEM_NAME,       --All table column
                                  ITEM_CODE,
                                  QUANTITY,
                                  ORGANIZATION_ID,
                                  FLAG)
                 VALUES (I.C001,                             --collection data
                         I.C002,
                         I.C003,
                         I.C004,
                         I.C005);
        END IF;
    END LOOP;

    COMMIT;
END;
