codeunit 50100 TaskletSubscriber
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB Application Configuration", 'OnGetApplicationConfiguration_OnAddTweaks', '', true, true)]
    local procedure OnGetApplicationConfiguration_OnAddTweaks(var _MobTweakContainer: Codeunit "MOB Tweak Container")
    var
        Tweak: Text;
    begin
        Tweak :=
            '<?xml version="1.0" encoding="utf-8"?>' +
            '<application xmlns="http://schemas.taskletfactory.com/MobileWMS/Application">' +
            '  <pages>' +
            '    <page id="JobRegistration" type="UnplannedItemRegistration" icon="stopwatch" tweak="Append">' +
            '      <title defaultValue="@{JobRegistration}" />' +
            '      <unplannedItemRegistrationConfiguration type="JobRegistration" useRegistrationCollector="true">' +
            '        <header configurationKey="JobRegistration" automaticAcceptOnOpen="true" clearAfterPost="true" />' +
            '      </unplannedItemRegistrationConfiguration>' +
            '    </page>' +
            '    <page id="MainMenu">' +
            '      <menuConfiguration>' +
            '        <menuItems>' +
            '          <menuItem id="JobRegistration" displayName="@{JobRegistration}" icon="stopwatch" tweak="Append" />' +
            '        </menuItems>' +
            '      </menuConfiguration>' +
            '    </page>' +
            '  </pages>' +
            '</application>';
        _MobTweakContainer.Add(1000, 'Page: JobRegistration', Tweak);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Language", 'OnAddMessages', '', true, true)]
    local procedure OnAddMessages(_LanguageCode: Code[10]; var _Messages: Record "MOB Message")
    var
        MOBMenuOption: Record "MOB Menu Option";
    begin

        // Create MOB Menu Option JobRegistration
        MOBMenuOption.Init();
        MOBMenuOption."Menu Option" := 'JobRegistration';
        If MOBMenuOption.Insert(True) then begin end;

        // Create English translation for my custom mobile message
        if _LanguageCode = 'ENU' then begin
            _Messages.Create('ENU', 'JobRegistration', 'Job Registration');
            _Messages.Create('ENU', 'EmployeeNo', 'Employee No.');
            _Messages.Create('ENU', 'JobNo', 'Job No.');
            _Messages.Create('ENU', 'ScanJobno', 'Scan Job no.');
            _Messages.Create('ENU', 'StopTime', 'Stop time');
            _Messages.Create('ENU', 'FinishJob', 'Finish job');
            _Messages.Create('ENU', 'FinishJobRegistration', 'Would you like to stop time/finish the job?');
        end;

        // Create Danish translation for my custom mobile message
        if _LanguageCode = 'DAN' then begin
            _Messages.Create('DAN', 'JobRegistration', 'Job registrering');
            _Messages.Create('DAN', 'EmployeeNo', 'Medarbejder nr.');
            _Messages.Create('DAN', 'ScanJobno', 'Scan Job nr.');
            _Messages.Create('DAN', 'StopTime', 'Stop tid');
            _Messages.Create('DAN', 'FinishJob', 'Afslut');
            _Messages.Create('DAN', 'FinishJobRegistration', 'Vil du stop tid/afslut jobbet?');
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Reference Data", 'OnGetReferenceData_OnAddHeaderConfigurations', '', true, true)]
    local procedure OnGetReferenceData_OnAddHeaderConfigurations(var _HeaderFields: Record "MOB HeaderField Element")
    begin
        _HeaderFields.InitConfigurationKey('JobRegistration');
        _HeaderFields.Create_TextField(10, 'EmployeeNo', '@{EmployeeNo}');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Reference Data", 'OnGetReferenceData_OnAddDataTables', '', true, true)]
    local procedure OnGetReferenceData_OnAddDataTables(var _DataTable: Record "MOB DataTable Element"; _MobileUserID: Code[50])
    Var
        MOBUser: Record "MOB User";
        MOBMessage: Record "MOB Message";
    begin
        MOBUser.Get(_MobileUserID);
        If MOBUser."Language Code" <> '' then begin
            MOBMessage.Reset();
            MOBMessage.SetRange("Language Code", MOBUser."Language Code");
        end else begin
            MOBMessage.Reset();
            MOBMessage.SetRange("Language Code", 'ENU');
        end;

        _DataTable.InitDataTable('FinishJobOptions');
        MOBMessage.SetRange(Code, 'STOPTIME');
        If MOBMessage.findset then begin
            _DataTable.Create_CodeAndName('STOP_TIME', MOBMessage.Message);
        end else begin
            _DataTable.Create_CodeAndName('STOP_TIME', 'Stop Time');
        end;

        MOBMessage.SetRange(Code, 'FINISHJOB');
        If MOBMessage.findset then begin
            _DataTable.Create_CodeAndName('FINISH_JOB', MOBMessage.Message);
        end else begin
            _DataTable.Create_CodeAndName('FINISH_JOB', 'Finish Job');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Adhoc Registr.", 'OnGetRegistrationConfiguration_OnAddSteps', '', true, true)]
    local procedure OnGetRegistrationConfiguration_OnAddSteps(_RegistrationType: Text; var _HeaderFieldValues: Record "MOB NS Request Element"; var _Steps: Record "MOB Steps Element"; var _RegistrationTypeTracking: Text)
    var
        EmployeeNo: Code[20];
    begin
        if _RegistrationType <> 'JobRegistration' then begin
            exit;
        end;

        EmployeeNo := CopyStr(_HeaderFieldValues.GetValue('EmployeeNo'), 1, MaxStrLen(EmployeeNo));

        CreateTextStep(_Steps, 10, 'JobNo', '@{JobNo}', '@{ScanJobno}');
        if EmployeeHasActiveProdJobs(EmployeeNo) then begin
            CreateFinishJobStep(_Steps);
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Adhoc Registr.", 'OnPostAdhocRegistrationOnCustomRegistrationType', '', true, true)]
    local procedure OnPostAdhocRegistrationOnCustomRegistrationType(_RegistrationType: Text; var _RequestValues: Record "MOB NS Request Element"; var _CurrentRegistrations: Record "MOB WMS Registration"; var _SuccessMessage: Text; var _RegistrationTypeTracking: Text; var _IsHandled: Boolean)
    var
        JobManEmployee: Record JobManEmployee;
        JobManJob: Record JobManJob;
        JobManApiRegistration: Codeunit JobManApiRegistration;
        ActiveJobs: Record JobManStampJournalLine;
        EmployeeNo: Code[20];
        JobNo: Code[20];
        FinishJobRegistration: Text[20];
        IsSameJobActive: Boolean;
    begin
        if _RegistrationType <> 'JobRegistration' then begin
            exit;
        end;

        if _IsHandled then begin
            exit;
        end;

        EmployeeNo := CopyStr(_RequestValues.GetValue('EmployeeNo'), 1, MaxStrLen(EmployeeNo));
        JobNo := CopyStr(_RequestValues.GetValue('JobNo'), 1, MaxStrLen(JobNo));
        FinishJobRegistration := _RequestValues.GetValue('FinishJobRegistration');

        if not JobManEmployee.Get(EmployeeNo) then begin
            Error(EmployeeNotFoundLbl, EmployeeNo);
        end;

        if not JobManEmployee.IsActive(Today()) then begin
            Error(EmployeeNotActiveLbl, EmployeeNo);
        end;

        // Find JobManJob record (kan angives med enten JobNo eller RefNo/Prod.ordrenr.)
        JobManJob.Reset();
        if not JobManJob.Get(JobNo) then begin
            JobManJob.SetRange(RefNo, JobNo);
            if not JobManJob.FindFirst() then begin
                Error(JobNotFoundLbl, JobNo);
            end;
        end;

        // Tjek om medarbejderen har aktive job
        GetActiveJobs(EmployeeNo, ActiveJobs);
        if ActiveJobs.FindSet(false) then begin
            IsSameJobActive := IsSameJobActive(EmployeeNo, JobManJob, JobNo);

            repeat
                if FinishJobRegistration = 'FINISH_JOB' then begin
                    JobManApiRegistration.JobFinish(GetApiId(), EmployeeNo, '', ActiveJobs.LineSequence);
                end else begin
                    JobManApiRegistration.JobStop(GetApiId(), EmployeeNo, '', ActiveJobs.LineSequence);
                end;
            until ActiveJobs.Next() = 0;

            /*
            if IsSameJobActive then begin
                _SuccessMessage := JobStoppedLbl;
                _IsHandled := true;
                exit;
            end;
            */
        end;

        // Hvis man ikke var på noget job, eller hvis man bippede et nyt job (og dermed stoppede det gamle):
        JobManApiRegistration.JobStart(GetApiId(), EmployeeNo, '', GetTimeOffsetUTC(), JobManJob.JobNo, false);
        _SuccessMessage := RegistrationCreatedLbl;
        _IsHandled := true;
    end;

    local procedure IsSameJobActive(EmployeeNo: Code[20]; JobManJob: Record JobManJob; ScannedJobNo: Code[20]): Boolean
    var
        ActiveJobsCheck: Record JobManStampJournalLine;
    begin
        if ActiveJobsCheck.FindActiveJobId(EmployeeNo, JobManJob.JobNo) then
            exit(true);
        if (JobManJob.RefNo <> '') and ActiveJobsCheck.FindActiveJobId(EmployeeNo, JobManJob.RefNo) then
            exit(true);
        if (ScannedJobNo <> '') and ActiveJobsCheck.FindActiveJobId(EmployeeNo, ScannedJobNo) then
            exit(true);
        exit(false);
    end;

    local procedure GetActiveJobs(EmployeeNo: Code[20]; var ActiveJobs: Record JobManStampJournalLine)
    var
        JobManJobBundle: Codeunit JobManJobBundle;
    begin
        ActiveJobs.Reset();
        JobManJobBundle.Init(EmployeeNo);
        JobManJobBundle.GetActiveJobs(ActiveJobs);
    end;

    local procedure CreateTextStep(var Steps: Record "MOB Steps Element"; StepId: Integer; StepName: Text; StepLabel: Text; StepHelpLabel: Text)
    begin
        Steps.InitConfigurationKey('JobRegistration');
        Steps.Create();
        Steps.Set_id(StepId);
        Steps.Set_name(StepName);
        Steps.Set_label(StepLabel);
        Steps.Set_helpLabel(StepHelpLabel);
        Steps.Set_inputType('Text');
        Steps.Save();
    end;

    local procedure CreateFinishJobStep(var Steps: Record "MOB Steps Element")
    begin
        Steps.InitConfigurationKey('JobRegistration');
        Steps.Create();
        Steps.Set_id(20);
        Steps.Set_name('FinishJobRegistration');
        Steps.Set_label('@{FinishJobRegistration}');
        Steps.Set_inputType('List');
        Steps.Set_dataTable('FinishJobOptions');
        Steps.Set_dataKeyColumn('Code');
        Steps.Set_dataDisplayColumn('Name');
        Steps.Set_defaultValue('STOP_TIME');
        Steps.Save();
    end;

    local procedure EmployeeHasActiveProdJobs(EmployeeNo: Code[20]): Boolean
    var
        ActiveJobs: Record JobManStampJournalLine;

    begin
        if EmployeeNo = '' then begin
            exit(false);
        end;

        GetActiveJobs(EmployeeNo, ActiveJobs);
        if ActiveJobs.FindSet(false) then begin
            repeat
                if ActiveJobs.RefType = ActiveJobs.RefType::Production then begin
                    exit(true);
                end;
            until ActiveJobs.Next() = 0;
        end;

        exit(false);
    end;

    local procedure GetApiId(): Code[10]
    begin
        exit('TASKLET');
    end;

    local procedure GetTimeOffsetUTC(): Integer
    begin
        exit(0);
    end;

    var
        RegistrationCreatedLbl: Label 'Registration created.';
        JobStoppedLbl: Label 'Active job stopped.';
        JobFinishedLbl: Label 'Active job finished.';
        EmployeeNotFoundLbl: Label 'Employee %1 was not found.';
        EmployeeNotActiveLbl: Label 'Employee %1 is not active.';
        JobNotFoundLbl: Label 'Job %1 was not found.';
}