*  ======================================================================*
*                                                                        *
*                          HR Solutions Tecnologia                       *
*                                                                        *
*  ======================================================================*
*   Empresa     : VOTORANTIM CIMENTOS                                    *
*   ID          : 13029                                                  *
*   Programa    : ZVCRHR0007_ROBO_SF                                     *
*   Tipo        : Interface Outbound                                     *
*   Módulo      : HCM                                                    *
*   Transação   : <Transação(ões) utilizada(s)>                          *
*   Descrição   : Programa para carregar os resultados das metas no      *
*                 no SuccessFactors usando WebService (SFAPI)            *
*   Autor       : Fábrica HRST                                           *
*   Data        : 05/10/2015                                             *
*  ----------------------------------------------------------------------*
*   Changes History                                                      *
*  ----------------------------------------------------------------------*
*   Data       | Autor     | Request    | Descrição                      *
*  ------------|-----------|------------|--------------------------------*
*   05/10/2014 |           | E03K9XYPTT | Início do desenvolvimento      *
*  ------------|-----------|------------|--------------------------------*
*  ======================================================================*
REPORT zvcrhr0007_robo_sf.

*  ----------------------------------------------------------------------*
*   Types                                                                *
*  ----------------------------------------------------------------------*
TYPES: BEGIN OF y_goallibraryentry,
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
      END OF y_goallibraryentry,

      BEGIN OF y_milestone,
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
      END OF y_milestone,

     BEGIN OF y_task,
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
    END OF y_task,

  BEGIN OF y_target,
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
  END OF y_target,

  BEGIN OF y_metriclookupentry,
    add TYPE string,
    nome_tabela TYPE string,
    guid TYPE string,
    parent_guid TYPE string,
    locale TYPE string,
    description TYPE string,
    rating TYPE string,
    achievement TYPE string,
    resto       TYPE string,
  END OF y_metriclookupentry,

  BEGIN OF y_check,
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
  END OF y_check,

  BEGIN OF y_arquivo,
      coluna TYPE string,
  END OF y_arquivo.

*  ----------------------------------------------------------------------*
*   Tabela Interna                                                       *
*  ----------------------------------------------------------------------*
DATA: t_goallibraryentry  TYPE TABLE OF y_goallibraryentry,
      t_milestone         TYPE TABLE OF y_milestone,
      t_task              TYPE TABLE OF y_task,
      t_target            TYPE TABLE OF y_target,
      t_metriclookupentry TYPE TABLE OF y_metriclookupentry,
      t_files             TYPE filetable,
      t_outdata           TYPE STANDARD TABLE OF y_arquivo,
      t_credenciais       TYPE TABLE OF ztbhr_sfsf_crede,
      t_log               TYPE TABLE OF ztbhr_sfsf_log,
      t_metas_sf          TYPE TABLE OF ztbhr_sfvc_metas,
      t_miles_sf          TYPE TABLE OF ztbhr_sfvc_mile,
      t_metric_sf          TYPE TABLE OF ztbhr_sfvc_metri.

*  ----------------------------------------------------------------------*
*   Work Area                                                            *
*  ----------------------------------------------------------------------*
DATA: w_goallibraryentry  TYPE y_goallibraryentry,
      w_milestone         TYPE y_milestone,
      w_task              TYPE y_task,
      w_target            TYPE y_target,
      w_metriclookupentry TYPE y_metriclookupentry,
      w_files             TYPE file_table,
      w_outdata           TYPE y_arquivo,
      w_check             TYPE y_check,
      w_log               TYPE ztbhr_sfsf_log,
      w_metas_sf          TYPE ztbhr_sfvc_metas,
      w_miles_sf          TYPE ztbhr_sfvc_mile,
      w_metric_sf         TYPE ztbhr_sfvc_metri.

*  ----------------------------------------------------------------------*
*   Variáveis                                                            *
*  ----------------------------------------------------------------------*
DATA: v_rc        TYPE i,
      v_linha     TYPE string,
      v_file      TYPE string,
      v_idlog     TYPE ztbhr_sfsf_log-idlog,
      v_seq       TYPE ztbhr_sfsf_log-seq.

*  ----------------------------------------------------------------------*
*   Constantes                                                           *
*  ----------------------------------------------------------------------*
CONSTANTS: c_error                TYPE c VALUE 'E',
           c_warning              TYPE c VALUE 'W',
           c_success              TYPE c VALUE 'S'.

*  ----------------------------------------------------------------------*
*   Tela de Seleção                                                      *
*  ----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-000.
PARAMETERS : p_file TYPE string DEFAULT 'C:\',
             p_deli TYPE c      DEFAULT ','.
SELECTION-SCREEN END OF BLOCK b1.

*SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-001.
*PARAMETERS:
*             p_10   as CHECKBOX,
*             p_12   as CHECKBOX,
*             p_13   as CHECKBOX,
*             p_14   as CHECKBOX,
*             p_15   as CHECKBOX,
*             p_16   as CHECKBOX,
*             p_204  as CHECKBOX,
*             p_303  as CHECKBOX,
*             p_305  as CHECKBOX,
*             p_306  as CHECKBOX,
*             p_403  as CHECKBOX,
*             p_405  as CHECKBOX,
*             p_406  as CHECKBOX,
*             p_9    as CHECKBOX.
*SELECTION-SCREEN END OF BLOCK b2.

*  ----------------------------------------------------------------------*
*   At Selection-Screen                                                  *
*  ----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    CHANGING
      file_table              = t_files
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

    READ TABLE t_files INTO w_files INDEX 1.
    p_file = w_files-filename.
  ENDIF.

*  ----------------------------------------------------------------------*
*   Start-Of-Selection                                                   *
*  ----------------------------------------------------------------------*
START-OF-SELECTION.

  SELECT *
    INTO TABLE t_credenciais
    FROM ztbhr_sfsf_crede.

  PERFORM zf_mensagem_progresso USING 'Carregando Arquivo da Biblioteca' ''.
  PERFORM zf_carregar_arquivo.
  PERFORM zf_ajustar_arquivo.
  PERFORM zf_split_dados.
  PERFORM zf_query_sfsf.
  PERFORM zf_verificar_metas.
  PERFORM zf_mensagem_progresso USING 'Atualizando Metas no SuccessFactors' ''.
  PERFORM zf_atualizar_metas_sf.
  PERFORM zf_atualizar_metric_sf.
  PERFORM zf_atualizar_mile_sf.

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
    codepage                      = '4110'
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

  LOOP AT t_outdata INTO w_outdata.

    TRANSLATE w_outdata-coluna USING '" '.

    SPLIT w_outdata-coluna AT p_deli INTO w_check-campo1
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
          SPLIT w_outdata-coluna AT p_deli INTO w_goallibraryentry-add
                                             w_goallibraryentry-nome_tabela
                                             w_goallibraryentry-guid
                                             w_goallibraryentry-parent_guid
                                             w_goallibraryentry-locale
                                             w_goallibraryentry-name
                                             w_goallibraryentry-metric
                                             w_goallibraryentry-desc
                                             w_goallibraryentry-start
                                             w_goallibraryentry-due
                                             w_goallibraryentry-done
                                             w_goallibraryentry-category
                                             w_goallibraryentry-weight
                                             w_goallibraryentry-state
                                             w_goallibraryentry-target_baseline
                                             w_goallibraryentry-goto_url
                                             w_goallibraryentry-rating
                                             w_goallibraryentry-achievement
                                             w_goallibraryentry-bizx_actual
                                             w_goallibraryentry-bizx_target
                                             w_goallibraryentry-bizx_pos
                                             w_goallibraryentry-bizx_strategic
                                             w_goallibraryentry-goal_score
                                             w_goallibraryentry-runrate
                                             w_goallibraryentry-runrate_forecast
                                             w_goallibraryentry-proposed_runrate
                                             w_goallibraryentry-fromlibrary
                                             w_goallibraryentry-status
                                             w_goallibraryentry-library
                                             w_goallibraryentry-bizx_effort_spent
                                             w_goallibraryentry-interpolacao
                                             w_goallibraryentry-type
                                             w_goallibraryentry-bizx_status_comments.

          APPEND w_goallibraryentry TO t_goallibraryentry.
          CLEAR w_goallibraryentry.


        WHEN 'Milestone'.
          SPLIT w_outdata-coluna AT p_deli INTO w_milestone-add
                                             w_milestone-nome_tabela
                                             w_milestone-guid
                                             w_milestone-parent_guid
                                             w_milestone-locale
                                             w_milestone-target
                                             w_milestone-actual
                                             w_milestone-desc
                                             w_milestone-start
                                             w_milestone-due
                                             w_milestone-completed
                                             w_milestone-customnum1
                                             w_milestone-customnum2
                                             w_milestone-customnum3
                                             w_milestone-weight
                                             w_milestone-rating
                                             w_milestone-score
                                             w_milestone-actualnumber
                                             w_milestone-resto.
          APPEND w_milestone TO t_milestone.
          CLEAR w_milestone.

        WHEN 'Task'.
          SPLIT w_outdata-coluna AT p_deli INTO w_task-add
                                             w_task-nome_tabela
                                             w_task-guid
                                             w_task-parent_guid
                                             w_task-locale
                                             w_task-target
                                             w_task-actual
                                             w_task-desc
                                             w_task-start
                                             w_task-due.
          APPEND w_task TO t_task.
          CLEAR w_task.

        WHEN 'Target'.
          SPLIT w_outdata-coluna AT p_deli INTO w_target-add
                                             w_target-nome_tabela
                                             w_target-guid
                                             w_target-parent_guid
                                             w_target-locale
                                             w_target-target
                                             w_target-actual
                                             w_target-desc
                                             w_target-start
                                             w_target-due
                                             w_target-done
                                             w_target-customnum1
                                             w_target-customnum2
                                             w_target-customnum3
                                             w_target-weight
                                             w_target-rating
                                             w_target-score
                                             w_target-actualnumber.
          APPEND w_target TO t_target.
          CLEAR w_target.

        WHEN 'MetricLookupEntry'.
          SPLIT w_outdata-coluna AT p_deli INTO w_metriclookupentry-add
                                             w_metriclookupentry-nome_tabela
                                             w_metriclookupentry-guid
                                             w_metriclookupentry-parent_guid
                                             w_metriclookupentry-locale
                                             w_metriclookupentry-description
                                             w_metriclookupentry-rating
                                             w_metriclookupentry-achievement
                                             w_metriclookupentry-resto.

          APPEND w_metriclookupentry TO t_metriclookupentry.
          CLEAR w_metriclookupentry.

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

  PERFORM zf_mensagem_progresso USING 'Processando os dados ' ''.

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

  DELETE t_metas WHERE library IS INITIAL.

  LOOP AT t_metas ASSIGNING <fs_metas>.

    CLEAR w_goallibraryentry.
    LOOP AT t_goallibraryentry INTO w_goallibraryentry WHERE guid = <fs_metas>-library.

      <fs_metas>-actual_achieveme = w_goallibraryentry-achievement.
      <fs_metas>-description      = w_goallibraryentry-desc.
      <fs_metas>-field_desc       = w_goallibraryentry-desc.
      <fs_metas>-name             = w_goallibraryentry-name.
      <fs_metas>-category         = w_goallibraryentry-category.
      <fs_metas>-metric           = w_goallibraryentry-metric.

      LOOP AT t_mile ASSIGNING <fs_milestone> WHERE goalid EQ <fs_metas>-id.

        CLEAR w_milestone.
        READ TABLE t_milestone INTO w_milestone WITH KEY guid = <fs_milestone>-guid BINARY SEARCH.

        IF sy-subrc EQ 0.

          <fs_milestone>-actualnumber = w_milestone-actualnumber.
          <fs_milestone>-customnum1 = w_milestone-customnum1.
          <fs_milestone>-customnum2 = w_milestone-customnum2.
          <fs_milestone>-customnum3 = w_milestone-customnum3.

        ENDIF.

      ENDLOOP.

      LOOP AT t_metric ASSIGNING <fs_metric> WHERE goalid EQ <fs_metas>-id.

        CLEAR w_metriclookupentry.
        READ TABLE t_metriclookupentry INTO w_metriclookupentry WITH KEY guid = <fs_metric>-subguid BINARY SEARCH.

        <fs_metric>-subguid       = w_metriclookupentry-guid.
        <fs_metric>-rating        = w_metriclookupentry-rating.
        <fs_metric>-achievement   = w_metriclookupentry-achievement.
        <fs_metric>-description   = w_metriclookupentry-description.

      ENDLOOP.

    ENDLOOP.

  ENDLOOP.

  MODIFY ztbhr_sfvc_metas FROM TABLE t_metas.
  MODIFY ztbhr_sfvc_metri FROM TABLE t_metric.
  MODIFY ztbhr_sfvc_mile  FROM TABLE t_mile.

ENDFORM.                    " ZF_VERIFICAR_METAS

*&---------------------------------------------------------------------*
*&      Form  zf_atualizar_metas_sf
*&---------------------------------------------------------------------*
FORM zf_atualizar_metas_sf.

  DATA: t_metas        TYPE TABLE OF ztbhr_sfvc_metas,
        t_data         TYPE zsfi_dt_operation_request_tab2, "*****
        w_data         LIKE LINE OF t_data,
        w_metas        LIKE LINE OF t_metas,
        w_old          LIKE w_metas,
        w_sfobject     TYPE LINE OF zsfi_dt_operation_request__tab,
        t_sfobject     TYPE zsfi_dt_operation_request__tab.

  DATA: w_credenciais       LIKE LINE OF t_credenciais,
        w_goallibraryentry  LIKE LINE OF t_goallibraryentry.

  DATA: l_batchsize TYPE i,
        l_sessionid TYPE string.

  DEFINE add_data.
    w_data-key = &1.
    w_data-value = &2.
    append w_data to t_data.
    clear w_data.
  END-OF-DEFINITION.

  SELECT *
    INTO TABLE t_credenciais
    FROM ztbhr_sfsf_crede
   WHERE empresa EQ 'VC'.

  READ TABLE t_credenciais INTO w_credenciais INDEX 1.

  SELECT *
    INTO TABLE t_metas
    FROM ztbhr_sfvc_metas.

  DELETE t_metas WHERE library IS INITIAL.

  SORT t_metas BY layout.

  LOOP AT t_metas INTO w_metas.

    IF w_metas-layout NE w_old-layout AND
       w_old-layout   NE space.

      PERFORM zf_call_update USING w_old-layout
                                   w_credenciais
                                   t_sfobject[].

      CLEAR: t_sfobject.

    ENDIF.

*    IF NOT w_metas-guid IS INITIAL.
*      add_data: 'guid'                  w_metas-guid.
*    ENDIF.

    IF w_metas-actual_achieveme IS INITIAL.
      w_metas-actual_achieveme = '0.00'.
    ENDIF.

    add_data:
              'flag'                  'Public',
*              'userId'                w_metas-userid,
              'status'                'read only',
              'description'           w_metas-description,
              'field_desc'            w_metas-field_desc,
              'name'                  w_metas-name,
              'actual_achievement'    w_metas-actual_achieveme,
              'category'              w_metas-category,
              'metric'                w_metas-metric.

    w_sfobject-entity = w_metas-layout.
    w_sfobject-id     = w_metas-id.
    w_sfobject-data   = t_data[].

    IF w_metas-name IS INITIAL OR
       w_metas-field_desc IS INITIAL OR
       w_metas-description IS INITIAL.
    ELSE.
      APPEND w_sfobject TO t_sfobject.
    ENDIF.
    CLEAR: w_sfobject, t_data[].

    w_old = w_metas.

  ENDLOOP.

  IF NOT t_sfobject[] IS INITIAL.

    PERFORM zf_call_update USING w_metas-layout
                                 w_credenciais
                                 t_sfobject[].

    CLEAR: t_sfobject.

  ENDIF.


ENDFORM.                    "zf_atualizar_metas_sf

*&---------------------------------------------------------------------*
*&      Form  zf_atualizar_metas_sf
*&---------------------------------------------------------------------*
FORM zf_atualizar_metric_sf.

  DATA: t_metric       TYPE TABLE OF ztbhr_sfvc_metri,
        t_data         TYPE zsfi_dt_operation_request_tab2, "*****
        w_data         LIKE LINE OF t_data,
        w_metric       LIKE LINE OF t_metric,
        w_old          LIKE w_metric,
        w_sfobject     TYPE LINE OF zsfi_dt_operation_request__tab,
        t_sfobject     TYPE zsfi_dt_operation_request__tab.

  DATA: w_credenciais       LIKE LINE OF t_credenciais,
        w_goallibraryentry  LIKE LINE OF t_goallibraryentry.

  DATA: l_batchsize TYPE i,
        l_sessionid TYPE string.

  DEFINE add_data.
    w_data-key = &1.
    w_data-value = &2.
    append w_data to t_data.
    clear w_data.
  END-OF-DEFINITION.

  SELECT *
    INTO TABLE t_credenciais
    FROM ztbhr_sfsf_crede
   WHERE empresa EQ 'VC'.

  READ TABLE t_credenciais INTO w_credenciais INDEX 1.

  SELECT *
    INTO TABLE t_metric
    FROM ztbhr_sfvc_metri.

  DELETE t_metric WHERE subguid IS INITIAL.

  SORT t_metric BY layout.

  LOOP AT t_metric INTO w_metric.

    IF w_metric-layout NE w_old-layout AND
       w_old-layout   NE space.

      PERFORM zf_call_upsert USING w_old-layout
                                   w_credenciais
                                   t_sfobject[].

      CLEAR: t_sfobject.

    ENDIF.

    add_data: 'subguid'               w_metric-subguid,
              'goalid'                w_metric-goalid,
              'rating'                w_metric-rating,
              'achievement'           w_metric-achievement,
              'description'           w_metric-description.

    w_sfobject-entity = w_metric-layout.
    w_sfobject-data   = t_data[].

    IF NOT w_metric-subguid IS INITIAL.
      APPEND w_sfobject TO t_sfobject.
    ENDIF.
    CLEAR: w_sfobject, t_data[].

    w_old = w_metric.

  ENDLOOP.

  IF NOT t_sfobject[] IS INITIAL.

    PERFORM zf_call_upsert USING w_metric-layout
                                 w_credenciais
                                 t_sfobject[].

    CLEAR: t_sfobject.

  ENDIF.

ENDFORM.                    "zf_atualizar_metric_sf

*&---------------------------------------------------------------------*
*&      Form  zf_atualizar_metas_sf
*&---------------------------------------------------------------------*
FORM zf_atualizar_mile_sf.

  DATA: t_mile         TYPE TABLE OF ztbhr_sfvc_mile,
        t_data         TYPE zsfi_dt_operation_request_tab2, "*****
        w_data         LIKE LINE OF t_data,
        w_mile         LIKE LINE OF t_mile,
        w_old          LIKE w_mile,
        w_sfobject     TYPE LINE OF zsfi_dt_operation_request__tab,
        t_sfobject     TYPE zsfi_dt_operation_request__tab.

  DATA: w_credenciais       LIKE LINE OF t_credenciais,
        w_goallibraryentry  LIKE LINE OF t_goallibraryentry.

  DATA: l_batchsize TYPE i,
        l_sessionid TYPE string.

  DEFINE add_data.
    w_data-key = &1.
    w_data-value = &2.
    append w_data to t_data.
    clear w_data.
  END-OF-DEFINITION.

  SELECT *
    INTO TABLE t_credenciais
    FROM ztbhr_sfsf_crede
   WHERE empresa EQ 'VC'.

  READ TABLE t_credenciais INTO w_credenciais INDEX 1.

  SELECT *
    INTO TABLE t_mile
    FROM ztbhr_sfvc_mile.

  DELETE t_mile WHERE guid IS INITIAL.

  SORT t_mile BY layout.

  LOOP AT t_mile INTO w_mile.

    IF w_mile-layout NE w_old-layout AND
       w_old-layout   NE space.

      PERFORM zf_call_upsert USING w_old-layout
                                    w_credenciais
                                    t_sfobject[].

      CLEAR: t_sfobject.

    ENDIF.

*    TRANSLATE w_mile-customnum1   USING '. '.
*    TRANSLATE w_mile-customnum2   USING '. '.
*    TRANSLATE w_mile-customnum3   USING '. '.
*    TRANSLATE w_mile-actualnumber USING '. '.
*
*    CONDENSE w_mile-customnum1    NO-GAPS.
*    CONDENSE w_mile-customnum2    NO-GAPS.
*    CONDENSE w_mile-customnum3    NO-GAPS.
*    CONDENSE w_mile-actualnumber  NO-GAPS.
*
*    TRANSLATE w_mile-customnum1   USING ',.'.
*    TRANSLATE w_mile-customnum2   USING ',.'.
*    TRANSLATE w_mile-customnum3   USING ',.'.
*    TRANSLATE w_mile-actualnumber USING ',.'.

    IF w_mile-customnum1 IS INITIAL.
      w_mile-customnum1 = '0.00'.
    ENDIF.

    IF w_mile-customnum2 IS INITIAL.
      w_mile-customnum2 = '0.00'.
    ENDIF.

    IF w_mile-customnum3 IS INITIAL.
      w_mile-customnum3 = '0.00'.
    ENDIF.

    IF w_mile-actualnumber IS INITIAL.
      w_mile-actualnumber = '0.00'.
    ENDIF.

    add_data: 'guid'                w_mile-guid,
              'goalid'              w_mile-goalid,
              'customnum1'          w_mile-customnum1,
              'customnum2'          w_mile-customnum2,
              'customnum3'          w_mile-customnum3,
              'actualnumber'        w_mile-actualnumber.

    w_sfobject-entity = w_mile-layout.
    w_sfobject-data   = t_data[].

    IF NOT w_mile-guid IS INITIAL.
      APPEND w_sfobject TO t_sfobject.
    ENDIF.
    CLEAR: w_sfobject, t_data[].

    w_old = w_mile.

  ENDLOOP.

  IF NOT t_sfobject[] IS INITIAL.
    PERFORM zf_call_upsert USING w_mile-layout
                                 w_credenciais
                                 t_sfobject[].

    CLEAR: t_sfobject.
  ENDIF.

ENDFORM.                    "zf_atualizar_mile_sf

*  &---------------------------------------------------------------------*
*  &      Form  ZF_LOGIN_SUCCESSFACTORS
*  &---------------------------------------------------------------------*
FORM zf_login_successfactors  USING    p_empresa
                              CHANGING c_sessionid
                                       c_batchsize.

  TYPES: BEGIN OF y_return_login,
           erro      TYPE c LENGTH 1,
           msg       TYPE string,
           sessionid TYPE string,
         END OF y_return_login.

  DATA: w_login             TYPE zmt_login_request,
        w_return_login      TYPE y_return_login,
        w_credenciais       LIKE LINE OF t_credenciais.

*  / Seleciona os dados de acesso da empresa
  READ TABLE t_credenciais INTO w_credenciais WITH KEY empresa = p_empresa BINARY SEARCH.
  IF sy-subrc NE 0.
    PERFORM zf_log USING space c_error text-009 p_empresa.
  ENDIF.
*  /

*  / Converte a senha para efetuar o Login
  PERFORM zf_decode_pass CHANGING w_credenciais-password.
*  /

  w_login-mt_login_request-credential-company_id = w_credenciais-companyid.
  w_login-mt_login_request-credential-username   = w_credenciais-username.
  w_login-mt_login_request-credential-password   = w_credenciais-password.

  PERFORM zf_login_success_factor(zvcrhr0006_sf_vc) USING w_login
                                                 CHANGING w_return_login.

  c_sessionid = w_return_login-sessionid.

ENDFORM.                    " ZF_LOGIN_SUCCESSFACTORS

*  &---------------------------------------------------------------------*
*  &      Form  ZF_LOG
*  &---------------------------------------------------------------------*
FORM zf_log  USING p_pernr
                   p_type
                   p_message1
                   p_message2.

  IF t_log[] IS INITIAL.

*     Seleciona o número do ID do LOG
    PERFORM zf_gera_id_log USING '01' 'ZHRGCA0027'
                           CHANGING v_idlog.
  ENDIF.

  ADD 1 TO v_seq.

  w_log-idlog   = v_idlog.
  w_log-pernr   = p_pernr.
  w_log-type    = p_type.
  CONCATENATE p_message1 p_message2 INTO w_log-message SEPARATED BY space.
  w_log-uname   = sy-uname.

  GET TIME.
  w_log-data    = sy-datum.
  w_log-hora    = sy-uzeit.

  w_log-seq     = v_seq.

  APPEND w_log TO t_log.
  CLEAR w_log.

ENDFORM.                    " ZF_LOG

*&---------------------------------------------------------------------*
*&      Form  ZF_GERA_ID_LOG
*&---------------------------------------------------------------------*
FORM zf_gera_id_log  USING    p_nr_range TYPE inri-nrrangenr
                              p_object   TYPE inri-object
                     CHANGING p_idlog.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = p_nr_range
      object                  = p_object
    IMPORTING
      number                  = p_idlog
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.

ENDFORM.                    " F_GERA_SERIAL

*  &---------------------------------------------------------------------*
*  &      Form  ZF_DECODE_PASS
*  &---------------------------------------------------------------------*
FORM zf_decode_pass CHANGING c_password.

  DATA: l_obj_utility TYPE REF TO cl_http_utility,
        l_pass        TYPE string.

  CREATE OBJECT l_obj_utility.

  l_pass = c_password.

  CALL METHOD l_obj_utility->decode_base64
    EXPORTING
      encoded = l_pass
    RECEIVING
      decoded = l_pass.

  c_password = l_pass.

ENDFORM.                    " ZF_DECODE_PASS

*  &---------------------------------------------------------------------*
*  &      Form  ZF_CALL_UPSERT
*  &---------------------------------------------------------------------*
FORM zf_call_upsert  USING i_entity
                           p_credenciais LIKE LINE OF t_credenciais
                           p_sfobject    TYPE zsfi_dt_operation_request__tab.

  DATA: l_count        TYPE i,
        l_count_tot    TYPE i,
        l_lote         TYPE i,
        l_o_erro       TYPE REF TO cx_root,
        l_o_erro_apl   TYPE REF TO cx_ai_application_fault,
        l_o_erro_fault TYPE REF TO zsfi_cx_dt_fault,
        l_text         TYPE string,
        l_sessionid    TYPE string,
        l_batchsize    TYPE i,
        l_tabix        TYPE sy-tabix,
        l_o_upsert     TYPE REF TO zsfi_co_si_upsert_request,
        w_request      TYPE zsfi_mt_operation_request,
        w_response     TYPE zsfi_mt_operation_response,
        w_result       TYPE LINE OF zsfi_mt_operation_response-mt_operation_response-object_edit_result,
        w_sfobject     TYPE LINE OF zsfi_dt_operation_request__tab,
        t_sfobject     TYPE zsfi_dt_operation_request__tab,
        w_sfparam      LIKE LINE OF w_request-mt_operation_request-processing_param,
        t_ztbhr_sfsf_user   TYPE TABLE OF ztbhr_sfsf_user,
        w_ztbhr_sfsf_user   TYPE ztbhr_sfsf_user,
        w_sfobject_data     LIKE LINE OF w_sfobject-data.

  IF lines( p_sfobject ) <= p_credenciais-batchsize.
    l_count = 1.
  ELSE.
    l_count = lines( p_sfobject ) / p_credenciais-batchsize.
  ENDIF.
  PERFORM zf_mensagem_progresso USING 'Atualizando ' i_entity.


  DO l_count TIMES.

    LOOP AT p_sfobject INTO w_sfobject FROM l_count_tot.

      l_tabix = sy-tabix.
      ADD 1 TO l_lote.
      ADD 1 TO l_count_tot.

      APPEND w_sfobject TO t_sfobject.
*        DELETE p_sfobject INDEX l_tabix.
      CLEAR w_sfobject.

      IF l_lote     EQ p_credenciais-batchsize OR
         l_count_tot  EQ lines( p_sfobject ).

        PERFORM zf_login_successfactors USING p_credenciais-empresa
                                     CHANGING l_sessionid
                                              l_batchsize.

        TRY.

            CREATE OBJECT l_o_upsert.

            w_request-mt_operation_request-entity     = i_entity.
            w_request-mt_operation_request-session_id = l_sessionid.
            w_request-mt_operation_request-sfobject   = t_sfobject.

            CALL METHOD l_o_upsert->si_upsert_request
              EXPORTING
                output = w_request
              IMPORTING
                input  = w_response.

            IF w_response-mt_operation_response-job_status EQ 'ERROR'.

              PERFORM zf_log USING space c_error 'Erro ao Efetuar Upsert para a Empresa'(020) p_credenciais-empresa.

              LOOP AT w_response-mt_operation_response-object_edit_result INTO w_result WHERE error_status EQ 'ERROR'.
                PERFORM zf_log USING space c_error w_result-message space.
              ENDLOOP.

            ELSE.

              PERFORM zf_log USING space c_success 'Upsert Efetuado com Sucesso para a Empresa'(023) p_credenciais-empresa.

            ENDIF.

            LOOP AT w_response-mt_operation_response-object_edit_result INTO w_result WHERE edit_status NE 'ERROR'.

              IF NOT w_result-id IS INITIAL.

                ADD 1 TO w_result-index.
                READ TABLE t_sfobject INTO w_sfobject INDEX w_result-index.
                READ TABLE w_sfobject-data INTO w_sfobject_data WITH KEY key = 'userId'.

              ENDIF.

            ENDLOOP.

*              MODIFY ztbhr_sfsf_user FROM TABLE t_ztbhr_sfsf_user.

          CATCH cx_ai_system_fault INTO l_o_erro.
            PERFORM zf_log USING space c_error 'Erro ao Efetuar Upsert para a Empresa'(020) p_credenciais-empresa.

            l_text = l_o_erro->get_text( ).
            PERFORM zf_log USING space c_error l_text space.

          CATCH zsfi_cx_dt_fault INTO l_o_erro_fault.
            PERFORM zf_log USING space c_error 'Erro ao Efetuar Upsert para a Empresa'(020) p_credenciais-empresa.

            l_text = l_o_erro_fault->standard-fault_text.
            PERFORM zf_log USING space c_error l_text space.

          CATCH cx_ai_application_fault INTO l_o_erro_apl.
            PERFORM zf_log USING space c_error 'Erro ao Efetuar Upsert para a Empresa'(020) p_credenciais-empresa.

            l_text = l_o_erro_apl->get_text( ).
            PERFORM zf_log USING space c_error l_text space.

        ENDTRY.

        CLEAR: l_lote,
               w_sfobject,
               t_sfobject.

      ENDIF.

    ENDLOOP.

  ENDDO.

ENDFORM.                    " ZF_CALL_UPSERT

*  &---------------------------------------------------------------------*
*  &      Form  ZF_QUERY_GOAL
*  &---------------------------------------------------------------------*
FORM zf_query_goal USING p_entity.

  DATA: l_count        TYPE i,
        l_count_tot    TYPE i,
        l_lote         TYPE i,
        l_o_erro       TYPE REF TO cx_root,
        l_o_erro_apl   TYPE REF TO cx_ai_application_fault,
        l_o_erro_fault TYPE REF TO zsfi_cx_dt_fault,
        l_text         TYPE string,
        l_sessionid    TYPE string,
        l_batchsize    TYPE i,
        l_tabix        TYPE sy-tabix,
        l_o_query      TYPE REF TO zsfi_co_si_query_goal_vc,
        w_request      TYPE zsf_mt_query_user_request,
        w_response     TYPE zsfi_mt_query_goal10_response,
        w_result       TYPE LINE OF zsfi_mt_operation_response-mt_operation_response-object_edit_result,
        t_sfobject     TYPE zsfi_dt_operation_request__tab,
        t_ztbhr_sfsf_user   TYPE TABLE OF ztbhr_sfsf_user,
        w_ztbhr_sfsf_user   TYPE ztbhr_sfsf_user,
        w_query             LIKE w_request-mt_query_user_request-query,
        w_sfobject          LIKE LINE OF w_response-mt_query_goal10_response-sfobject,
        l_has_more          TYPE c,
        l_deleted           TYPE string,
        l_goal              TYPE string,
        l_username          TYPE string.

  DEFINE add_internal_table.

    w_metas_sf-layout = w_sfobject-type.
    w_metas_sf-id = w_sfobject-id.
    w_metas_sf-guid = w_sfobject-guid.
    w_metas_sf-masterid = w_sfobject-master_id.
    w_metas_sf-lastmodified = w_sfobject-last_modified.
    w_metas_sf-modifier = w_sfobject-modifier.
    w_metas_sf-currentowner = w_sfobject-current_owner.
    w_metas_sf-numbering = w_sfobject-numbering.
    w_metas_sf-goaltype = w_sfobject-goal_type.
    w_metas_sf-flag = w_sfobject-flag.
    w_metas_sf-parentid = w_sfobject-parent_id.
    w_metas_sf-userid = w_sfobject-user_id.
    w_metas_sf-username = w_sfobject-user_name.
    w_metas_sf-status = w_sfobject-status.
    w_metas_sf-dept = w_sfobject-dept.
    w_metas_sf-div = w_sfobject-div.
    w_metas_sf-loc = w_sfobject-loc.
    w_metas_sf-defgrp = w_sfobject-def_grp.
    w_metas_sf-bizxlaststatusit = w_sfobject-bizx_last_status_item_id.
    w_metas_sf-bizxlastupdatere = w_sfobject-bizxlast_update_request_id.
    w_metas_sf-description = w_sfobject-description.
    w_metas_sf-library = w_sfobject-library.
    w_metas_sf-fromlibrary = w_sfobject-fromlibrary.
    w_metas_sf-name = w_sfobject-name.
    w_metas_sf-field_desc = w_sfobject-field_desc.
    w_metas_sf-weight = w_sfobject-weight.
    w_metas_sf-metric = w_sfobject-metric.
    w_metas_sf-actual_achieveme = w_sfobject-actual_achievement.
    w_metas_sf-rating = w_sfobject-rating.
    w_metas_sf-goal_score = w_sfobject-goal_score.
    w_metas_sf-bizx_target = w_sfobject-bizx_target.
    w_metas_sf-interpolacao = w_sfobject-interpolacao.
    w_metas_sf-bizx_actual = w_sfobject-bizx_actual.
    w_metas_sf-category = w_sfobject-category.

    append w_metas_sf to t_metas_sf.
    clear w_metas_sf.

  END-OF-DEFINITION.

  PERFORM zf_mensagem_progresso USING 'Selecionando ' p_entity.

  PERFORM zf_login_successfactors USING 'VC'
                               CHANGING l_sessionid
                                        l_batchsize.



  TRY.

      CREATE OBJECT l_o_query.
      l_deleted = text-001 && 'deleted'&& text-001.
      l_goal = text-001 && 'GOAL-12051' && text-001.
      l_username = text-001 && 'vid_vcnet@paulorlc'&& text-001.

      CONCATENATE 'select id, guid, masterid, modifier, currentOwner, numbering,'
                  'goaltype, flag, parentid, userid, username, status, library,'
                  'fromlibrary, lastModified, actual_achievement,'
                  'rating, goal_score, bizx_target, interpolacao, bizx_actual, category, metricLookupAchievementType'
                  ' from '
                  p_entity
                  'where status != '
                  l_deleted
*                  'and id !=' l_goal
*                  'and username =' l_username
             INTO w_query-query_string SEPARATED BY space.

      w_request-mt_query_user_request-query      = w_query.
      w_request-mt_query_user_request-session_id = 'JSESSIONID=' && l_sessionid.

      CALL METHOD l_o_query->si_query_goal10
        EXPORTING
          output = w_request
        IMPORTING
          input  = w_response.

    CATCH cx_ai_system_fault INTO l_o_erro.
      PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

      l_text = l_o_erro->get_text( ).
      PERFORM zf_log USING space c_error l_text space.

    CATCH zsfi_cx_dt_fault INTO l_o_erro_fault.
      PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

      l_text = l_o_erro_fault->standard-fault_text.
      PERFORM zf_log USING space c_error l_text space.

    CATCH cx_ai_application_fault INTO l_o_erro_apl.
      PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

      l_text = l_o_erro_apl->get_text( ).
      PERFORM zf_log USING space c_error l_text space.

  ENDTRY.

  LOOP AT w_response-mt_query_goal10_response-sfobject INTO w_sfobject.

    add_internal_table.

  ENDLOOP.

*/ QueryMore
  DATA: l_query_more        TYPE REF TO zsfi_co_si_querymore_goal_vc,
        w_request_more      TYPE zsfi_mt_query_more_request,
        w_response_more     TYPE zsfi_mt_query_more_goal10_resp,
        l_tentativa         TYPE i.

  l_has_more = w_response-mt_query_goal10_response-has_more.

  WHILE l_has_more EQ abap_true.

    w_request_more-mt_query_more_request-session_id = w_request-mt_query_user_request-session_id.
    w_request_more-mt_query_more_request-query-query_session_id = w_response-mt_query_goal10_response-query_session_id.

    TRY.

        CREATE OBJECT l_query_more.

        CALL METHOD l_query_more->si_query_goal10
          EXPORTING
            output = w_request_more
          IMPORTING
            input  = w_response_more.

      CATCH cx_ai_system_fault INTO l_o_erro.
        PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

        l_text = l_o_erro->get_text( ).
        PERFORM zf_log USING space c_error l_text space.

      CATCH zsfi_cx_dt_fault INTO l_o_erro_fault.
        PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

        l_text = l_o_erro_fault->standard-fault_text.
        PERFORM zf_log USING space c_error l_text space.

      CATCH cx_ai_application_fault INTO l_o_erro_apl.
        PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

        l_text = l_o_erro_apl->get_text( ).
        PERFORM zf_log USING space c_error l_text space.

    ENDTRY.

    LOOP AT w_response_more-mt_query_more_goal10_response-sfobject INTO w_sfobject.

      add_internal_table.

    ENDLOOP.

    IF l_tentativa EQ 0.
      l_has_more = abap_true.
    ELSE.
      l_has_more = w_response_more-mt_query_more_goal10_response-has_more.
    ENDIF.

    ADD 1 TO l_tentativa.

  ENDWHILE.
*/

ENDFORM.                    " ZF_QUERY_GOAL

*&---------------------------------------------------------------------*
*&      Form  zf_query_sfsf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zf_query_sfsf.

  PERFORM zf_mensagem_progresso USING 'Selecionando dados do SuccessFactors' ''.

*  PERFORM zf_query_goal USING 'Goal$204'.
  PERFORM zf_query_goal USING 'Goal$303'.
*  PERFORM zf_query_goal USING 'Goal$305'.
*  PERFORM zf_query_goal USING 'Goal$306'.
*  PERFORM zf_query_goal USING 'Goal$403'.
*  PERFORM zf_query_goal USING 'Goal$405'.
*  PERFORM zf_query_goal USING 'Goal$406'.
*  PERFORM zf_query_goal USING 'Goal$9'.
*  PERFORM zf_query_goal USING 'Goal$10'.
*  PERFORM zf_query_goal USING 'Goal$12'.
*  PERFORM zf_query_goal USING 'Goal$13'.
*  PERFORM zf_query_goal USING 'Goal$14'.
*  PERFORM zf_query_goal USING 'Goal$15'.
*  PERFORM zf_query_goal USING 'Goal$16'.

*  PERFORM zf_query_metriclookup USING 'GoalMetricLookup$204'.
  PERFORM zf_query_metriclookup USING 'GoalMetricLookup$303'.
*  PERFORM zf_query_metriclookup USING 'GoalMetricLookup$305'.
*  PERFORM zf_query_metriclookup USING 'GoalMetricLookup$306'.
*  PERFORM zf_query_metriclookup USING 'GoalMetricLookup$403'.
*  PERFORM zf_query_metriclookup USING 'GoalMetricLookup$405'.
*  PERFORM zf_query_metriclookup USING 'GoalMetricLookup$406'.
*  PERFORM zf_query_metriclookup USING 'GoalMetricLookup$9'.
*  PERFORM zf_query_metriclookup USING 'GoalMetricLookup$10'.
*  PERFORM zf_query_metriclookup USING 'GoalMetricLookup$12'.
*  PERFORM zf_query_metriclookup USING 'GoalMetricLookup$13'.
*  PERFORM zf_query_metriclookup USING 'GoalMetricLookup$14'.
*  PERFORM zf_query_metriclookup USING 'GoalMetricLookup$15'.
*  PERFORM zf_query_metriclookup USING 'GoalMetricLookup$16'.

*  PERFORM zf_query_milestone USING 'GoalMilestone$204'.
  PERFORM zf_query_milestone USING 'GoalMilestone$303'.
*  PERFORM zf_query_milestone USING 'GoalMilestone$305'.
*  PERFORM zf_query_milestone USING 'GoalMilestone$306'.
*  PERFORM zf_query_milestone USING 'GoalMilestone$403'.
*  PERFORM zf_query_milestone USING 'GoalMilestone$405'.
*  PERFORM zf_query_milestone USING 'GoalMilestone$406'.
*  PERFORM zf_query_milestone USING 'GoalMilestone$9'.
*  PERFORM zf_query_milestone USING 'GoalMilestone$10'.
*  PERFORM zf_query_milestone USING 'GoalMilestone$12'.
*  PERFORM zf_query_milestone USING 'GoalMilestone$13'.
*  PERFORM zf_query_milestone USING 'GoalMilestone$14'.
*  PERFORM zf_query_milestone USING 'GoalMilestone$15'.
*  PERFORM zf_query_milestone USING 'GoalMilestone$16'.

  MODIFY ztbhr_sfvc_metas FROM TABLE t_metas_sf.
  MODIFY ztbhr_sfvc_mile  FROM TABLE t_miles_sf.
  MODIFY ztbhr_sfvc_metri  FROM TABLE t_metric_sf.

ENDFORM.                    "zf_query_sfsf

*  &---------------------------------------------------------------------*
*  &      Form  ZF_QUERY_MILESTONE
*  &---------------------------------------------------------------------*
FORM zf_query_milestone USING p_entity.

  DATA: l_count        TYPE i,
        l_count_tot    TYPE i,
        l_lote         TYPE i,
        l_o_erro       TYPE REF TO cx_root,
        l_o_erro_apl   TYPE REF TO cx_ai_application_fault,
        l_o_erro_fault TYPE REF TO zsfi_cx_dt_fault,
        l_text         TYPE string,
        l_sessionid    TYPE string,
        l_batchsize    TYPE i,
        l_tabix        TYPE sy-tabix,
        l_o_query      TYPE REF TO zsfi_co_si_query_milestone_vc,
        w_request      TYPE zsf_mt_query_user_request,
        w_response     TYPE zsfi_mt_query_milestone_response,
        w_result       TYPE LINE OF zsfi_mt_operation_response-mt_operation_response-object_edit_result,
        t_sfobject     TYPE zsfi_dt_operation_request__tab,
        t_ztbhr_sfsf_user   TYPE TABLE OF ztbhr_sfsf_user,
        w_ztbhr_sfsf_user   TYPE ztbhr_sfsf_user,
        w_query             LIKE w_request-mt_query_user_request-query,
        w_sfobject          LIKE LINE OF w_response-mt_query_milestone_response-sfobject,
        l_has_more          TYPE c.

  DEFINE add_internal_table.

    w_miles_sf-layout = w_sfobject-type.
    w_miles_sf-id = w_sfobject-id.
    w_miles_sf-guid = w_sfobject-guid.
    w_miles_sf-goalid = w_sfobject-goal_id.
    w_miles_sf-masterid = w_sfobject-master_id.
    w_miles_sf-lastmodified = w_sfobject-last_modified.
    w_miles_sf-modifier = w_sfobject-modifier.
    w_miles_sf-displayorder = w_sfobject-display_order.
    w_miles_sf-field_desc = w_sfobject-field_desc.
    w_miles_sf-customnum1 = w_sfobject-custom_num1.
    w_miles_sf-customnum2 = w_sfobject-custom_num2.
    w_miles_sf-customnum3 = w_sfobject-custom_num3.
    w_miles_sf-actualnumber = w_sfobject-actual_number.
    w_miles_sf-rating = w_sfobject-rating.

    append w_miles_sf to t_miles_sf.
    clear w_miles_sf.

  END-OF-DEFINITION.

  PERFORM zf_mensagem_progresso USING 'Selecionando ' p_entity.

  PERFORM zf_login_successfactors USING 'VC'
                               CHANGING l_sessionid
                                        l_batchsize.

  TRY.

      CREATE OBJECT l_o_query.

      CONCATENATE 'select id, guid, goalid, masterid, lastmodified, modifier,'
                  'displayorder, customnum1, customnum2, customnum3,'
                  'actualnumber, rating'
                  'from'
                  p_entity
             INTO w_query-query_string SEPARATED BY space.

      w_request-mt_query_user_request-query      = w_query.
      w_request-mt_query_user_request-session_id = 'JSESSIONID=' && l_sessionid.

      CALL METHOD l_o_query->si_query_goal10
        EXPORTING
          output = w_request
        IMPORTING
          input  = w_response.

    CATCH cx_ai_system_fault INTO l_o_erro.
      PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

      l_text = l_o_erro->get_text( ).
      PERFORM zf_log USING space c_error l_text space.

    CATCH zsfi_cx_dt_fault INTO l_o_erro_fault.
      PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

      l_text = l_o_erro_fault->standard-fault_text.
      PERFORM zf_log USING space c_error l_text space.

    CATCH cx_ai_application_fault INTO l_o_erro_apl.
      PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

      l_text = l_o_erro_apl->get_text( ).
      PERFORM zf_log USING space c_error l_text space.

  ENDTRY.

  LOOP AT w_response-mt_query_milestone_response-sfobject INTO w_sfobject.

    add_internal_table.

  ENDLOOP.

*/ QueryMore
  DATA: l_query_more        TYPE REF TO zsfi_co_si_querymore_milestone,
        w_request_more      TYPE zsfi_mt_query_more_request,
        w_response_more     TYPE zsfi_mt_query_more_milestone_r,
        l_tentativa         TYPE i.

  l_has_more = w_response-mt_query_milestone_response-has_more.

  WHILE l_has_more EQ abap_true.

    w_request_more-mt_query_more_request-session_id = w_request-mt_query_user_request-session_id.
    w_request_more-mt_query_more_request-query-query_session_id = w_response-mt_query_milestone_response-query_session_id.

    TRY.

        CREATE OBJECT l_query_more.

        CALL METHOD l_query_more->si_query_goal10
          EXPORTING
            output = w_request_more
          IMPORTING
            input  = w_response_more.

      CATCH cx_ai_system_fault INTO l_o_erro.
        PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

        l_text = l_o_erro->get_text( ).
        PERFORM zf_log USING space c_error l_text space.

      CATCH zsfi_cx_dt_fault INTO l_o_erro_fault.
        PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

        l_text = l_o_erro_fault->standard-fault_text.
        PERFORM zf_log USING space c_error l_text space.

      CATCH cx_ai_application_fault INTO l_o_erro_apl.
        PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

        l_text = l_o_erro_apl->get_text( ).
        PERFORM zf_log USING space c_error l_text space.

    ENDTRY.

    LOOP AT w_response_more-mt_query_more_milestone_respon-sfobject INTO w_sfobject.

      add_internal_table.

    ENDLOOP.

    IF l_tentativa EQ 0.
      l_has_more = abap_true.
    ELSE.
      l_has_more = w_response_more-mt_query_more_milestone_respon-has_more.
    ENDIF.

    ADD 1 TO l_tentativa.

  ENDWHILE.

*/

ENDFORM.                    " ZF_QUERY_MILESTONE

*&---------------------------------------------------------------------*
*&      Form  zf_call_update
*&---------------------------------------------------------------------*
FORM zf_call_update USING i_entity
                          p_credenciais LIKE LINE OF t_credenciais
                          p_sfobject    TYPE zdt_operation_request_sfob_tab.

  DATA: l_count        TYPE i,
        l_count_tot    TYPE i,
        l_lote         TYPE i,
        l_o_erro       TYPE REF TO cx_root,
        l_o_erro_apl   TYPE REF TO cx_ai_application_fault,
        l_o_erro_fault TYPE REF TO zsfi_cx_dt_fault,
        l_text         TYPE string,
        l_sessionid    TYPE string,
        l_batchsize    TYPE i,
        l_tabix        TYPE sy-tabix,
        l_o_update     TYPE REF TO zco_si_update_request,
        w_request      TYPE zmt_operation_request,
        w_response     TYPE zmt_operation_response,
        w_result       TYPE LINE OF zsfi_mt_operation_response-mt_operation_response-object_edit_result, """"""""""""""
        w_sfobject     TYPE LINE OF zsfi_dt_operation_request__tab,
        t_sfobject     TYPE zsfi_dt_operation_request__tab,
        w_sfparam      LIKE LINE OF w_request-mt_operation_request-processing_param,
        t_ztbhr_sfsf_user   TYPE TABLE OF ztbhr_sfsf_user,
        w_ztbhr_sfsf_user   TYPE ztbhr_sfsf_user,
        w_sfobject_data     LIKE LINE OF w_sfobject-data.

  IF lines( p_sfobject ) <= p_credenciais-batchsize.
    l_count = 1.
  ELSE.
    l_count = lines( p_sfobject ) / p_credenciais-batchsize.
  ENDIF.

  PERFORM zf_mensagem_progresso USING 'Atualizando ' i_entity.

  DO l_count TIMES.

    LOOP AT p_sfobject INTO w_sfobject FROM l_count_tot.

      l_tabix = sy-tabix.
      ADD 1 TO l_lote.
      ADD 1 TO l_count_tot.

      APPEND w_sfobject TO t_sfobject.
*        DELETE p_sfobject INDEX l_tabix.
      CLEAR w_sfobject.

      IF l_lote     EQ p_credenciais-batchsize OR
         l_count_tot  EQ lines( p_sfobject ).

        PERFORM zf_login_successfactors USING p_credenciais-empresa
                                     CHANGING l_sessionid
                                              l_batchsize.

        TRY.

            CREATE OBJECT l_o_update.

            w_request-mt_operation_request-entity     = i_entity.
            w_request-mt_operation_request-session_id = l_sessionid.
            w_request-mt_operation_request-sfobject   = t_sfobject.

            CALL METHOD l_o_update->si_update_request
              EXPORTING
                output = w_request
              IMPORTING
                input  = w_response.

            IF w_response-mt_operation_response-job_status EQ 'ERROR'.

              PERFORM zf_log USING space c_error 'Erro ao Efetuar Upsert para a Empresa'(020) p_credenciais-empresa.

              LOOP AT w_response-mt_operation_response-object_edit_result INTO w_result WHERE error_status EQ 'ERROR'.
                PERFORM zf_log USING space c_error w_result-message space.
              ENDLOOP.

            ELSE.

              PERFORM zf_log USING space c_success 'Upsert Efetuado com Sucesso para a Empresa'(023) p_credenciais-empresa.

            ENDIF.

            LOOP AT w_response-mt_operation_response-object_edit_result INTO w_result WHERE edit_status NE 'ERROR'.

              IF NOT w_result-id IS INITIAL.

                ADD 1 TO w_result-index.
                READ TABLE t_sfobject INTO w_sfobject INDEX w_result-index.
                READ TABLE w_sfobject-data INTO w_sfobject_data WITH KEY key = 'userId'.

              ENDIF.

            ENDLOOP.

*              MODIFY ztbhr_sfsf_user FROM TABLE t_ztbhr_sfsf_user.

          CATCH cx_ai_system_fault INTO l_o_erro.
            PERFORM zf_log USING space c_error 'Erro ao Efetuar Upsert para a Empresa'(020) p_credenciais-empresa.

            l_text = l_o_erro->get_text( ).
            PERFORM zf_log USING space c_error l_text space.

          CATCH zsfi_cx_dt_fault INTO l_o_erro_fault.
            PERFORM zf_log USING space c_error 'Erro ao Efetuar Upsert para a Empresa'(020) p_credenciais-empresa.

            l_text = l_o_erro_fault->standard-fault_text.
            PERFORM zf_log USING space c_error l_text space.

          CATCH cx_ai_application_fault INTO l_o_erro_apl.
            PERFORM zf_log USING space c_error 'Erro ao Efetuar Upsert para a Empresa'(020) p_credenciais-empresa.

            l_text = l_o_erro_apl->get_text( ).
            PERFORM zf_log USING space c_error l_text space.

        ENDTRY.

        CLEAR: l_lote,
               w_sfobject,
               t_sfobject.

      ENDIF.

    ENDLOOP.

  ENDDO.

ENDFORM.                    " ZF_CALL_UPDATE

*  &---------------------------------------------------------------------*
*  &      Form  ZF_MENSAGEM_PROGRESSO
*  &---------------------------------------------------------------------*
FORM zf_mensagem_progresso  USING p_msg1
                                  p_msg2.

  DATA: l_msg TYPE string.

  IF sy-batch EQ abap_true.

*          MESSAGE p_msg TYPE 'I'.

  ELSE.

    l_msg = p_msg1 && p_msg2.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        text = l_msg.

  ENDIF.

ENDFORM.                    " ZF_MENSAGEM_PROGRESSO

*  &---------------------------------------------------------------------*
*  &      Form  zf_query_metriclookup
*  &---------------------------------------------------------------------*
FORM zf_query_metriclookup USING p_entity.

  DATA: l_count        TYPE i,
        l_count_tot    TYPE i,
        l_lote         TYPE i,
        l_o_erro       TYPE REF TO cx_root,
        l_o_erro_apl   TYPE REF TO cx_ai_application_fault,
        l_o_erro_fault TYPE REF TO zsfi_cx_dt_fault,
        l_text         TYPE string,
        l_sessionid    TYPE string,
        l_batchsize    TYPE i,
        l_tabix        TYPE sy-tabix,
        l_o_query      TYPE REF TO zsfi_co_si_query_metriclookup,
        w_request      TYPE zsf_mt_query_user_request,
        w_response     TYPE zsfi_mt_query_metric_lookup_re,
        w_result       TYPE LINE OF zsfi_mt_operation_response-mt_operation_response-object_edit_result,
        t_sfobject     TYPE zsfi_dt_operation_request__tab,
        t_ztbhr_sfsf_user   TYPE TABLE OF ztbhr_sfsf_user,
        w_ztbhr_sfsf_user   TYPE ztbhr_sfsf_user,
        w_query             LIKE w_request-mt_query_user_request-query,
        w_sfobject          LIKE LINE OF w_response-mt_query_metric_lookup_respons-sfobject,
        l_has_more          TYPE c.

  DEFINE add_internal_table.

    w_metric_sf-layout = w_sfobject-type.
    w_metric_sf-id = w_sfobject-id.
    w_metric_sf-subguid = w_sfobject-subguid.
    w_metric_sf-goalid = w_sfobject-goal_id.
    w_metric_sf-masterid = w_sfobject-master_id.
    w_metric_sf-lastmodified = w_sfobject-last_modified.
    w_metric_sf-displayorder = w_sfobject-display_order.
    w_metric_sf-rating = w_sfobject-rating.
    w_metric_sf-achievement = w_sfobject-achievement.
    w_metric_sf-description = w_sfobject-description.

    append w_metric_sf to t_metric_sf.
    clear w_metric_sf.

  END-OF-DEFINITION.

  PERFORM zf_mensagem_progresso USING 'Selecionando ' p_entity.

  PERFORM zf_login_successfactors USING 'VC'
                               CHANGING l_sessionid
                                        l_batchsize.

  TRY.

      CREATE OBJECT l_o_query.

      CONCATENATE 'select id, subguid, goalid, masterid, lastmodified, '
                  'displayorder, rating, achievement'
                  'from '
                  p_entity
             INTO w_query-query_string SEPARATED BY space.

      w_request-mt_query_user_request-query      = w_query.
      w_request-mt_query_user_request-session_id = 'JSESSIONID=' && l_sessionid.

      CALL METHOD l_o_query->si_query_goal10
        EXPORTING
          output = w_request
        IMPORTING
          input  = w_response.

    CATCH cx_ai_system_fault INTO l_o_erro.
      PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

      l_text = l_o_erro->get_text( ).
      PERFORM zf_log USING space c_error l_text space.

    CATCH zsfi_cx_dt_fault INTO l_o_erro_fault.
      PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

      l_text = l_o_erro_fault->standard-fault_text.
      PERFORM zf_log USING space c_error l_text space.

    CATCH cx_ai_application_fault INTO l_o_erro_apl.
      PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

      l_text = l_o_erro_apl->get_text( ).
      PERFORM zf_log USING space c_error l_text space.

  ENDTRY.

  LOOP AT w_response-mt_query_metric_lookup_respons-sfobject INTO w_sfobject.

    add_internal_table.

  ENDLOOP.

*/ QueryMore
  DATA: l_query_more        TYPE REF TO zsfi_co_si_querymore_metricloo,
        w_request_more      TYPE zsfi_mt_query_more_request,
        w_response_more     TYPE zsfi_mt_query_more_metric_look,
        l_tentativa         TYPE i.

  l_has_more = w_response-mt_query_metric_lookup_respons-has_more.

  WHILE l_has_more EQ abap_true.

    w_request_more-mt_query_more_request-session_id = w_request-mt_query_user_request-session_id.
    w_request_more-mt_query_more_request-query-query_session_id = w_response-mt_query_metric_lookup_respons-query_session_id.

    TRY.

        CREATE OBJECT l_query_more.

        CALL METHOD l_query_more->si_query_goal10
          EXPORTING
            output = w_request_more
          IMPORTING
            input  = w_response_more.

      CATCH cx_ai_system_fault INTO l_o_erro.
        PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

        l_text = l_o_erro->get_text( ).
        PERFORM zf_log USING space c_error l_text space.

      CATCH zsfi_cx_dt_fault INTO l_o_erro_fault.
        PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

        l_text = l_o_erro_fault->standard-fault_text.
        PERFORM zf_log USING space c_error l_text space.

      CATCH cx_ai_application_fault INTO l_o_erro_apl.
        PERFORM zf_log USING space c_error 'Erro ao Efetuar QUERY para a Empresa'(020) ''.

        l_text = l_o_erro_apl->get_text( ).
        PERFORM zf_log USING space c_error l_text space.

    ENDTRY.

    LOOP AT w_response_more-mt_query_more_metric_lookup_re-sfobject INTO w_sfobject.

      add_internal_table.

    ENDLOOP.

    IF l_tentativa EQ 0.
      l_has_more = abap_true.
    ELSE.
      l_has_more = w_response_more-mt_query_more_metric_lookup_re-has_more.
    ENDIF.

    ADD 1 TO l_tentativa.

  ENDWHILE.
*/

ENDFORM.                    " zf_query_metriclookup

*&---------------------------------------------------------------------*
*&      Form  zf_ajustar_arquivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zf_ajustar_arquivo.

  DATA: w_outdata LIKE LINE OF t_outdata,
        w_old     LIKE LINE OF t_outdata.

  DATA: lv_tabix      TYPE sy-tabix,
        lv_mod        TYPE c,
        lv_len        TYPE i.

  LOOP AT t_outdata INTO w_outdata.

    lv_len = strlen( w_outdata-coluna ).

    IF  w_outdata-coluna IS INITIAL
    OR  lv_len LE 5
    OR  ( w_outdata-coluna(4) NE 'TYPE'
        AND w_outdata-coluna(6) NE 'ACTION'
        AND w_outdata-coluna(6) NE 'HEADER'
        AND w_outdata-coluna(3) NE 'ADD' ).

      w_old-coluna = w_old-coluna && cl_abap_char_utilities=>cr_lf && w_outdata-coluna.
      lv_mod = abap_true.

      IF lv_tabix IS INITIAL.
        lv_tabix = sy-tabix - 1.
      ENDIF.

    ELSE.

      IF lv_mod EQ abap_true.

        READ TABLE t_outdata INTO w_outdata INDEX lv_tabix.

        w_outdata-coluna = w_outdata-coluna && w_old-coluna.
        MODIFY t_outdata FROM w_outdata INDEX lv_tabix.

        CLEAR: w_old,
               lv_tabix,
               lv_mod.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                    "zf_ajustar_arquivo
