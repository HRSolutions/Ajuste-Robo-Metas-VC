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
      t_log               TYPE TABLE OF ztbhr_sfsf_log.

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
      w_log               TYPE ztbhr_sfsf_log.

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
             p_deli TYPE c      DEFAULT ';'.
SELECTION-SCREEN END OF BLOCK b1.

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

  PERFORM zf_carregar_arquivo.

  PERFORM zf_split_dados.

  PERFORM zf_query_goal.

  PERFORM zf_verificar_metas.

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

  LOOP AT t_outdata INTO w_outdata.

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
                                             w_milestone-actualnumber.
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
                                             w_metriclookupentry-achievement.

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

  LOOP AT t_metas ASSIGNING <fs_metas> WHERE NOT library IS INITIAL.

    READ TABLE t_goallibraryentry INTO w_goallibraryentry WITH KEY guid = <fs_metas>-library BINARY SEARCH.

    <fs_metas>-actual_achieveme = w_goallibraryentry-achievement.

    LOOP AT t_mile ASSIGNING <fs_milestone> WHERE goalid EQ <fs_metas>-id.

      READ TABLE t_milestone INTO w_milestone WITH KEY guid = <fs_milestone>-guid BINARY SEARCH.

      <fs_milestone>-actualnumber = w_milestone-actualnumber.
      <fs_milestone>-customnum1 = w_milestone-customnum1.
      <fs_milestone>-customnum2 = w_milestone-customnum2.
      <fs_milestone>-customnum3 = w_milestone-customnum3.

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

  SORT t_metas BY layout.

  LOOP AT t_metas INTO w_metas.

    IF w_metas-layout NE w_old-layout AND
       w_old-layout   NE space.

      w_sfobject-entity = w_old-layout.
      w_sfobject-data   = t_data[].
      APPEND w_sfobject TO t_sfobject.
      CLEAR: w_sfobject, t_data[].

      PERFORM zf_call_upsert USING w_old-layout
                                    w_credenciais
                                    t_sfobject[].

      CLEAR: t_sfobject.

    ENDIF.

    add_data: 'guid'                  w_metas-guid,
              'flag'                  'Public',
              'userId'                w_metas-userid,
              'status'                'read only',
              'description'           w_metas-description,
              'field_desc'            w_metas-field_desc,
              'name'                  w_metas-name,
              'actual_achievement'    w_metas-actual_achieveme,
              'category'              w_metas-category.

    w_old = w_metas.

  ENDLOOP.

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

  SORT t_metric BY layout.

  LOOP AT t_metric INTO w_metric.

    IF w_metric-layout NE w_old-layout AND
       w_old-layout   NE space.

      w_sfobject-entity = w_old-layout.
      w_sfobject-data   = t_data[].
      APPEND w_sfobject TO t_sfobject.
      CLEAR: w_sfobject, t_data[].

      PERFORM zf_call_upsert USING w_old-layout
                                    w_credenciais
                                    t_sfobject[].

      CLEAR: t_sfobject.

    ENDIF.

    add_data: 'subguid'               w_metric-subguid,
              'goalid'                w_metric-goalid,
              'masterid'              w_metric-masterid,
              'rating'                w_metric-rating,
              'achievement'           w_metric-achievement,
              'description'           w_metric-description.

    w_old = w_metric.

  ENDLOOP.

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

  SORT t_mile BY layout.

  LOOP AT t_mile INTO w_mile.

    IF w_mile-layout NE w_old-layout AND
       w_old-layout   NE space.

      w_sfobject-entity = w_old-layout.
      w_sfobject-data   = t_data[].
      APPEND w_sfobject TO t_sfobject.
      CLEAR: w_sfobject, t_data[].

      PERFORM zf_call_upsert USING w_old-layout
                                    w_credenciais
                                    t_sfobject[].

      CLEAR: t_sfobject.

    ENDIF.

    add_data: 'guid'                w_mile-guid,
              'goalid'              w_mile-goalid,
              'masterid'            w_mile-masterid,
              'customnum1'          w_mile-customnum1,
              'customnum2'          w_mile-customnum2,
              'customnum3'          w_mile-customnum3,
              'actualnumber'        w_mile-actualnumber,
              'rating'              w_mile-rating.

    w_old = w_mile.

  ENDLOOP.

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
FORM zf_query_goal.

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
        w_sfobject     TYPE LINE OF zsfi_dt_operation_request__tab,
        t_sfobject     TYPE zsfi_dt_operation_request__tab,
        t_ztbhr_sfsf_user   TYPE TABLE OF ztbhr_sfsf_user,
        w_ztbhr_sfsf_user   TYPE ztbhr_sfsf_user,
        w_sfobject_data     LIKE LINE OF w_sfobject-data,
        w_query             LIKE w_request-mt_query_user_request-query.

  PERFORM zf_login_successfactors USING 'VC'
                               CHANGING l_sessionid
                                        l_batchsize.

  TRY.

      CREATE OBJECT l_o_query.

      w_query-query_string = 'select id, guid, masterid, modifier, currentOwner, numbering,'
                &&  'goaltype, flag, parentid, userid, username, status, description, library,'
                &&  'fromlibrary, lastModified, name, field_desc, metric, actual_achievement,'
                &&  'rating, goal_score, bizx_target, interpolacao, bizx_actual, category, metricLookupAchievementType'
                &&  'from Goal$303'.
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

ENDFORM.                    " ZF_QUERY_GOAL
