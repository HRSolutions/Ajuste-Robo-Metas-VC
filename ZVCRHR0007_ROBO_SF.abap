*&---------------------------------------------------------------------*
*& Report  ZVCRHR0007_ROBO_SF
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ZVCRHR0007_ROBO_SF.

data : BEGIN OF y_goallibraryentry,
      add TYPE string,
      nome_tabela TYPE string,
      guid TYPE string,
      parent_guid TYPE string,
      locale TYPE string,
      name TYPE string,
      metric TYPE string,
      desc TYPE string,
      start TYPE string,
      due TYPE string,
      done TYPE string,
      category TYPE string,
      weight TYPE string,
      state TYPE string,
      target_baseline TYPE string,
      goto_url TYPE string,
      rating TYPE string,
      achievement TYPE string,
      bizx_actual TYPE string,
      bizx_target TYPE string,
      bizx_pos TYPE string,
      bizx_strategic TYPE string,
      goal_score TYPE string,
      runrate TYPE string,
      runrate_forecast TYPE string,
      proposed_runrate TYPE string,
      fromlibrary TYPE string,
      status TYPE string,
      library TYPE string,
      bizx_effort_spent TYPE string,
      interpolacao TYPE string,
      type TYPE string,
      bizx_status_comments TYPE string,
  END OF y_goallibraryentry.

DATA: BEGIN OF y_milestone,
       add TYPE string,
       nome_tabela TYPE string,
       guid TYPE string,
       parent_guid TYPE string,
       locale TYPE string,
       target TYPE string,
       actual TYPE string,
       desc TYPE string,
       start TYPE string,
       due TYPE string,
       completed TYPE string,
       customnum1 TYPE string,
       customnum2 TYPE string,
       customnum3 TYPE string,
       weight TYPE string,
       rating TYPE string,
       score TYPE string,
       actualnumber TYPE string,
       resto TYPE string,
  END OF y_milestone.

DATA: BEGIN OF y_task,
      add TYPE string,
      nome_tabela TYPE string,
      guid TYPE string,
      parent_guid TYPE string,
      locale TYPE string,
      target TYPE string,
      actual TYPE string,
      desc TYPE string,
      start TYPE string,
      due TYPE string,
      done TYPE string ,
  END OF y_task.

DATA:BEGIN OF y_target,
    add TYPE string,
    nome_tabela TYPE string,
    guid TYPE string,
    parent_guid TYPE string,
    locale TYPE string,
    target TYPE string,
    actual TYPE string,
    desc TYPE string,
    start TYPE string,
    due TYPE string,
    done TYPE string,
    customnum1 TYPE string,
    customnum2 TYPE string,
    customnum3 TYPE string,
    weight TYPE string,
    rating TYPE string,
    score TYPE string,
    actualnumber TYPE string,
  END OF y_target.

DATA:BEGIN OF y_metriclookupentry OCCURS 0,
  add TYPE string,
  nome_tabela TYPE string,
  guid TYPE string,
  parent_guid TYPE string,
  locale TYPE string,
  description TYPE string,
  rating TYPE string,
  achievement TYPE string,
  resto       TYPE string,
  END OF y_metriclookupentry.

DATA:BEGIN OF w_check OCCURS 0,
    campo1 TYPE string,
    campo2 TYPE string,
    campo3 TYPE string,
    campo4 TYPE string,
    campo5 TYPE string,
    campo6 TYPE string,
    campo7 TYPE string,
    campo8 TYPE string,
    campo9 TYPE string,
    campo10 TYPE string,
    campo11 TYPE string,
    campo12 TYPE string,
    campo13 TYPE string,
    campo14 TYPE string,
    campo15 TYPE string,
    campo16 TYPE string,
    campo17 TYPE string,
    campo18 TYPE string,
    campo19 TYPE string,
    campo20 TYPE string,
    campo21 TYPE string,
    campo22 TYPE string,
    campo23 TYPE string,
    campo24 TYPE string,
    campo25 TYPE string,
    campo26 TYPE string,
    campo27 TYPE string,
    campo28 TYPE string,
    campo29 TYPE string,
    campo30 TYPE string,
    campo31 TYPE string,
    campo32 TYPE string,
    campo33 TYPE string,
  END OF w_check.

TYPES:BEGIN OF y_arquivo,
      coluna TYPE string,
  END OF y_arquivo.

DATA: t_outdata TYPE STANDARD TABLE OF y_arquivo.
DATA: w_outdata TYPE ty_arquivo.
DATA: lv_file TYPE string.

DATA t_files TYPE filetable.
DATA wa_files TYPE file_table.
DATA v_rc     TYPE i.
DATA v_linha TYPE string.

DATA: T_goallibraryentry  TYPE TABLE OF y_goallibraryentry,
      t_milestone         TYPE TABLE OF y_milestone,
      t_task              TYPE TABLE OF Y_TASK,
      t_target            TYPE TABLE OF Y_MASK,
      T_METRICLOOKUPENTRY TYPE TABLE OF y_metriclookupentry.

      DATA: W_goallibraryentry  TYPE y_goallibraryentry,
            W_milestone         TYPE y_milestone,
            W_task              TYPE Y_TASK,
            W_target            TYPE Y_MASK,
            W_METRICLOOKUPENTRY TYPE Ty_metriclookupentry.

PARAMETERS : p_file TYPE string DEFAULT 'C:\',
             p_deli TYPE c      DEFAULT ';'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    CHANGING
      file_table              = it_files
      rc                      = v_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.

    READ TABLE it_files INTO wa_files INDEX 1.
    p_file = wa_files-filename.
  ENDIF.

START-OF-SELECTION.

  PERFORM zf_carregar_arquivo.

  PERFORM zf_split_dados.

  PERFORM zf_verificar_metas.

*&---------------------------------------------------------------------*
*&      Form  ZF_CARREGAR_ARQUIVO
*&---------------------------------------------------------------------*
FORM zf_carregar_arquivo .

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                     = p_file
     filetype                      = 'ASC'
*    HAS_FIELD_SEPARATOR           = ' '
*    HEADER_LENGTH                 = 0
*    READ_BY_LINE                  = 'X'
*    DAT_MODE                      = ' '
*    CODEPAGE                      = ' '
*    IGNORE_CERR                   = ABAP_TRUE
*    REPLACEMENT                   = '#'
*    CHECK_BOM                     = ' '
*    VIRUS_SCAN_PROFILE            =
*    NO_AUTH_CHECK                 = ' '
*  IMPORTING
*    FILELENGTH                    =
*    HEADER                        =
    TABLES
      data_tab                      = t_outdata
*  EXCEPTIONS
*    FILE_OPEN_ERROR               = 1
*    FILE_READ_ERROR               = 2
*    NO_BATCH                      = 3
*    GUI_REFUSE_FILETRANSFER       = 4
*    INVALID_TYPE                  = 5
*    NO_AUTHORITY                  = 6
*    UNKNOWN_ERROR                 = 7
*    BAD_DATA_FORMAT               = 8
*    HEADER_NOT_ALLOWED            = 9
*    SEPARATOR_NOT_ALLOWED         = 10
*    HEADER_TOO_LONG               = 11
*    UNKNOWN_DP_ERROR              = 12
*    ACCESS_DENIED                 = 13
*    DP_OUT_OF_MEMORY              = 14
*    DISK_FULL                     = 15
*    DP_TIMEOUT                    = 16
*    OTHERS                        = 17
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.                    " ZF_CARREGAR_ARQUIVO

*&---------------------------------------------------------------------*
*&      Form  ZF_SPLIT_DADOS
*&---------------------------------------------------------------------*
FORM zf_split_dados .


  LOOP AT t_outdata INTO W_OUTDATA.

    SPLIT W_outdata-coluna AT p_deli INTO w_check-campo1
                                       w_check-campo2
                                       w_check-campo3
                                       w_check-campo4
                                       w_check-campo5
                                       w_check-campo6
                                       w_check-campo7
                                       w_check-campo8
                                       w_check-campo9
                                       w_check-campo10
                                       w_check-campo11
                                       w_check-campo12
                                       w_check-campo13
                                       w_check-campo14
                                       w_check-campo15
                                       w_check-campo16
                                       w_check-campo17
                                       w_check-campo18
                                       w_check-campo19
                                       w_check-campo20
                                       w_check-campo21
                                       w_check-campo22
                                       w_check-campo23
                                       w_check-campo24
                                       w_check-campo25
                                       w_check-campo26
                                       w_check-campo27
                                       w_check-campo28
                                       w_check-campo29
                                       w_check-campo30
                                       w_check-campo31
                                       w_check-campo32
                                       w_check-campo33.

    IF w_check-campo1 EQ 'ADD'.

      CASE w_check-campo2.
        WHEN 'GoalLibraryEntry'.
          SPLIT W_outdata-coluna AT p_deli INTO t_goallibraryentry-add
                                             t_goallibraryentry-nome_tabela
                                             t_goallibraryentry-guid
                                             t_goallibraryentry-parent_guid
                                             t_goallibraryentry-locale
                                             t_goallibraryentry-name
                                             t_goallibraryentry-metric
                                             t_goallibraryentry-desc
                                             t_goallibraryentry-start
                                             t_goallibraryentry-due
                                             t_goallibraryentry-done
                                             t_goallibraryentry-category
                                             t_goallibraryentry-weight
                                             t_goallibraryentry-state
                                             t_goallibraryentry-target_baseline
                                             t_goallibraryentry-goto_url
                                             t_goallibraryentry-rating
                                             t_goallibraryentry-achievement
                                             t_goallibraryentry-bizx_actual
                                             t_goallibraryentry-bizx_target
                                             t_goallibraryentry-bizx_pos
                                             t_goallibraryentry-bizx_strategic
                                             t_goallibraryentry-goal_score
                                             t_goallibraryentry-runrate
                                             t_goallibraryentry-runrate_forecast
                                             t_goallibraryentry-proposed_runrate
                                             t_goallibraryentry-fromlibrary
                                             t_goallibraryentry-status
                                             t_goallibraryentry-library
                                             t_goallibraryentry-bizx_effort_spent
                                             t_goallibraryentry-interpolacao
                                             t_goallibraryentry-type
                                             t_goallibraryentry-bizx_status_comments.

          APPEND t_goallibraryentry.
          CLEAR t_goallibraryentry.


        WHEN 'Milestone'.
          SPLIT W_outdata-coluna AT p_deli INTO t_milestone-add
                                             t_milestone-nome_tabela
                                             t_milestone-guid
                                             t_milestone-parent_guid
                                             t_milestone-locale
                                             t_milestone-target
                                             t_milestone-actual
                                             t_milestone-desc
                                             t_milestone-start
                                             t_milestone-due
                                             t_milestone-completed
                                             t_milestone-customnum1
                                             t_milestone-customnum2
                                             t_milestone-customnum3
                                             t_milestone-weight
                                             t_milestone-rating
                                             t_milestone-score
                                             t_milestone-actualnumber.
          APPEND t_milestone.
          CLEAR t_milestone.

        WHEN 'Task'.
          SPLIT t_outdata-coluna AT p_deli INTO t_task-add
                                             t_task-nome_tabela
                                             t_task-guid
                                             t_task-parent_guid
                                             t_task-locale
                                             t_task-target
                                             t_task-actual
                                             t_task-desc
                                             t_task-start
                                             t_task-due.
          APPEND t_task.
          CLEAR t_task.
        WHEN 'Target'.
          SPLIT W_outdata-coluna AT p_deli INTO t_target-add
                                             t_target-nome_tabela
                                             t_target-guid
                                             t_target-parent_guid
                                             t_target-locale
                                             t_target-target
                                             t_target-actual
                                             t_target-desc
                                             t_target-start
                                             t_target-due
                                             t_target-done
                                             t_target-customnum1
                                             t_target-customnum2
                                             t_target-customnum3
                                             t_target-weight
                                             t_target-rating
                                             t_target-score
                                             t_target-actualnumber.
          APPEND t_target.
          CLEAR t_target.

        WHEN 'MetricLookupEntry'.
          SPLIT t_outdata-coluna AT p_deli INTO t_metriclookupentry-add
                                             t_metriclookupentry-nome_tabela
                                             t_metriclookupentry-guid
                                             t_metriclookupentry-parent_guid
                                             t_metriclookupentry-locale
                                             t_metriclookupentry-description
                                             t_metriclookupentry-rating
                                             t_metriclookupentry-achievement.

          APPEND t_metriclookupentry.
          CLEAR t_metriclookupentry.

        WHEN OTHERS.

      ENDCASE.

    ELSE.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " ZF_SPLIT_DADOS

*&---------------------------------------------------------------------*
*&      Form  ZF_VERIFICAR_METAS
*&---------------------------------------------------------------------*
FORM zf_verificar_metas .

  DATA: t_metas             TYPE TABLE OF ztbhr_sfvc_metas,
        t_mile              TYPE TABLE OF ztbhr_sfvc_mile,
        t_metric            TYPE TABLE OF ztbhr_sfvc_metri,
        w_milestone         LIKE LINE OF t_milestone,
        w_metriclookupentry LIKE LINE OF t_metriclookupentry,
        w_goallibraryentry  LIKE LINE OF t_goallibraryentry.

  FIELD-SYMBOLS: <fs_metas>     LIKE LINE OF t_metas,
                 <fs_milestone> LIKE LINE OF t_mile,
                 <fs_metric>    LIKE LINE OF t_metric.

  SELECT *
    INTO TABLE t_metas
    FROM ztbhr_sfvc_metas.

  SELECT *
    INTO TABLE t_mile
    FROM ztbhr_sfvc_mile.

  SELECT *
    INTO TABLE t_metric
    FROM ztbhr_sfvc_metri.

  SORT: t_goallibraryentry  BY guid,
        t_milestone         BY guid,
        t_metriclookupentry BY guid.

  LOOP AT t_metas ASSIGNING <fs_metas>.

    READ TABLE t_goallibraryentry INTO w_goallibraryentry WITH KEY guid = <fs_metas>-guid BINARY SEARCH.

    <fs_metas>-actual_achieveme = w_goallibraryentry-achievement.

  ENDLOOP.

  LOOP AT t_mile ASSIGNING <fs_milestone>.

    READ TABLE t_milestone INTO w_milestone WITH KEY guid = <fs_milestone>-guid BINARY SEARCH.

    <fs_milestone>-actualnumber = w_milestone-actualnumber.
    <fs_milestone>-customnum1 = w_milestone-customnum1.
    <fs_milestone>-customnum2 = w_milestone-customnum2.
    <fs_milestone>-customnum3 = w_milestone-customnum3.

  ENDLOOP.

  LOOP AT t_metric ASSIGNING <fs_metric>.

    READ TABLE t_metriclookupentry INTO w_metriclookupentry WITH KEY guid = <fs_metric>-subguid BINARY SEARCH.

    <fs_metric>-achievement = w_metriclookupentry-achievement.

  ENDLOOP.

  MODIFY ztbhr_sfvc_metas FROM TABLE t_metas.
  MODIFY ztbhr_sfvc_metri FROM TABLE t_metric.
  MODIFY ztbhr_sfvc_mile  FROM TABLE t_mile.

ENDFORM.                    " ZF_VERIFICAR_METAS
