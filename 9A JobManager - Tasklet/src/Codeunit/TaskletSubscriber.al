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
            '      <title defaultValue="Job registration" />' +
            '      <unplannedItemRegistrationConfiguration type="JobRegistration" useRegistrationCollector="false">' +
            '        <header configurationKey="JobRegistration" automaticAcceptOnOpen="true" clearAfterPost="true" />' +
            '      </unplannedItemRegistrationConfiguration>' +
            '    </page>' +
            '    <page id="MainMenu">' +
            '      <menuConfiguration>' +
            '        <menuItems>' +
            '          <menuItem id="JobRegistration" displayName="Job registration" icon="stopwatch" tweak="Append" />' +
            '        </menuItems>' +
            '      </menuConfiguration>' +
            '    </page>' +
            '  </pages>' +
            '</application>';
        _MobTweakContainer.Add(1000, 'Page: JobRegistration', Tweak);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Reference Data", 'OnGetReferenceData_OnAddHeaderConfigurations', '', true, true)]
    local procedure OnGetReferenceData_OnAddHeaderConfigurations(var _HeaderFields: Record "MOB HeaderField Element")
    begin
        _HeaderFields.InitConfigurationKey('JobRegistration');
        _HeaderFields.Create_TextField(10, 'EmployeeNo', 'Employee');
        _HeaderFields.Create_TextField(20, 'JobType', 'Type (IPO, SAG or Production)');
        _HeaderFields.Create_TextField(30, 'JobNo', 'Job number');
        _HeaderFields.Create_ListField(40, 'FinishJobRegistration', 'Afslut job');
        _HeaderFields.Set_listValues('true:Ja;false:Nej');
        _HeaderFields.Set_defaultValue('false');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Adhoc Registr.", 'OnGetRegistrationConfiguration_OnAddSteps', '', true, true)]
    local procedure OnGetRegistrationConfiguration_OnAddSteps(_RegistrationType: Text; var _HeaderFieldValues: Record "MOB NS Request Element"; var _Steps: Record "MOB Steps Element"; var _RegistrationTypeTracking: Text)
    begin
        if _RegistrationType <> 'JobRegistration' then begin
            exit;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Adhoc Registr.", 'OnPostAdhocRegistrationOnCustomRegistrationType', '', true, true)]
    local procedure OnPostAdhocRegistrationOnCustomRegistrationType(_RegistrationType: Text; var _RequestValues: Record "MOB NS Request Element"; var _CurrentRegistrations: Record "MOB WMS Registration"; var _SuccessMessage: Text; var _RegistrationTypeTracking: Text; var _IsHandled: Boolean)
    var
        JobManEmployee: Record JobManEmployee;
        JobManJob: Record JobManJob;
        JobManJobBundle: Codeunit JobManJobBundle;
        TmpJobManBundleLine: Record JobManBundleLine temporary;
        EmployeeNo: Code[20];
        JobType: Text;
        JobNo: Code[20];
        FinishJobRegistration: Boolean;
        IsSameJobActive: Boolean;
    begin
        if _RegistrationType <> 'JobRegistration' then begin
            exit;
        end;

        if _IsHandled then begin
            exit;
        end;

        EmployeeNo := CopyStr(_RequestValues.GetValue('EmployeeNo'), 1, MaxStrLen(EmployeeNo));
        JobType := UpperCase(_RequestValues.GetValue('JobType'));
        JobNo := CopyStr(_RequestValues.GetValue('JobNo'), 1, MaxStrLen(JobNo));
        FinishJobRegistration := _RequestValues.GetValueAsBoolean('FinishJobRegistration');

        if not JobManEmployee.Get(EmployeeNo) then begin
            Error(EmployeeNotFoundLbl, EmployeeNo);
        end;

        if not JobManEmployee.IsActive(Today()) then begin
            Error(EmployeeNotActiveLbl, EmployeeNo);
        end;

        // Find JobManJob record (kan angives med enten JobNo eller RefNo/Prod.ordrenr.)
        if not JobManJob.Get(JobNo) then begin
            JobManJob.SetRange(RefNo, JobNo);
            if not JobManJob.FindFirst() then begin
                Error(JobNotFoundLbl, JobNo);
            end;
        end;

        // Tjek om medarbejderen har aktive job
        JobManJobBundle.Init(EmployeeNo);
        JobManJobBundle.GetTmpJobManBundleLine(TmpJobManBundleLine);

        if not TmpJobManBundleLine.IsEmpty() then begin
            // Undersøg om det scannede job allerede er aktivt
            IsSameJobActive := false;
            if TmpJobManBundleLine.FindSet() then begin
                repeat
                    if (TmpJobManBundleLine.JobNo = JobNo) or (TmpJobManBundleLine.JobNo = JobManJob.JobNo) then begin
                        IsSameJobActive := true;
                    end;
                until TmpJobManBundleLine.Next() = 0;
            end;

            // Stop det aktuelt aktive job
            JobManJobBundle.ParmAskForFeedback(false);
            if FinishJobRegistration then begin
                JobManJobBundle.ActiveJobsFeedbackReportFinishSetYes();
            end else begin
                JobManJobBundle.ActiveJobsFeedbackReportFinishSetNo();
            end;

            JobManJobBundle._ActiveJobsStop();
            JobManJobBundle.MakeRegistrations(); // Poster stoppet i databasen

            if IsSameJobActive then begin
                if FinishJobRegistration then begin
                    _SuccessMessage := JobFinishedLbl;
                end else begin
                    _SuccessMessage := JobStoppedLbl;
                end;
                _IsHandled := true;
                exit;
            end;
        end;

        // Hvis man ikke var på noget job, eller hvis man bippede et nyt job (og dermed stoppede det gamle):
        RegisterJob(EmployeeNo, JobType, JobManJob.JobNo);
        _SuccessMessage := RegistrationCreatedLbl;
        _IsHandled := true;
    end;

    local procedure RegisterJob(EmployeeNo: Code[20]; JobType: Text; JobNo: Code[20])
    var
        JobManEmployee: Record JobManEmployee;
        JobManJob: Record JobManJob;
        JobManIpcActivity: Record JobManIpcActivity;
        JobManBundleLine: Record JobManBundleLine;
        JobManMakeRegistration: Codeunit JobManMakeRegistration;
    begin
        if not JobManEmployee.Get(EmployeeNo) then begin
            Error(EmployeeNotFoundLbl, EmployeeNo);
        end;

        if not JobManEmployee.IsActive(Today()) then begin
            Error(EmployeeNotActiveLbl, EmployeeNo);
        end;

        if not JobManJob.Get(JobNo) then begin
            JobManJob.SetRange(RefNo, JobNo);
            if not JobManJob.FindFirst() then begin
                Error(JobNotFoundLbl, JobNo);
            end;
        end;

        JobManMakeRegistration.Init(EmployeeNo, CurrentDateTime(), Today(), CurrentDateTime(), 0);

        case JobType of
            'IPO':
                begin
                    if JobManJob.RefType <> JobManJob.RefType::IPC then begin
                        Error(JobTypeMismatchLbl, JobNo, JobType);
                    end;

                    if not JobManIpcActivity.Find_JobNo(JobManJob.JobNo) then begin
                        Error(IpcActivityNotFoundLbl, JobNo);
                    end;

                    JobManMakeRegistration.MakeRegistration_IPC(JobManIpcActivity, true);
                end;
            'SAG':
                begin
                    if JobManJob.RefType <> JobManJob.RefType::Job then begin
                        Error(JobTypeMismatchLbl, JobNo, JobType);
                    end;

                    JobManBundleLine.InitFrom_JobManJob(JobManJob);
                    JobManBundleLine.Counter := 1;
                    JobManMakeRegistration.MakeRegistration_Job(JobManBundleLine);
                end;
            'PRODUCTION':
                begin
                    if JobManJob.RefType <> JobManJob.RefType::Production then begin
                        Error(JobTypeMismatchLbl, JobNo, JobType);
                    end;

                    JobManBundleLine.InitFrom_JobManJob(JobManJob);
                    JobManBundleLine.Counter := 1;
                    JobManMakeRegistration.MakeRegistration_Production(JobManBundleLine);
                end;
            else begin
                Error(UnsupportedJobTypeLbl, JobType);
            end;
        end;
    end;

    var
        RegistrationCreatedLbl: Label 'Registration created.';
        JobStoppedLbl: Label 'Active job stopped.';
        JobFinishedLbl: Label 'Active job finished.';
        EmployeeNotFoundLbl: Label 'Employee %1 was not found.';
        EmployeeNotActiveLbl: Label 'Employee %1 is not active.';
        JobNotFoundLbl: Label 'Job %1 was not found.';
        IpcActivityNotFoundLbl: Label 'IPO activity for job %1 was not found.';
        JobTypeMismatchLbl: Label 'Job %1 does not match type %2.';
        UnsupportedJobTypeLbl: Label 'Job type %1 is not supported. Use IPO, SAG or Production.';
}