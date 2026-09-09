codeunit 50100 TaskletSubscriber
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB Application Configuration", 'OnGetApplicationConfiguration_OnAddTweaks', '', true, true)]
    local procedure OnGetApplicationConfiguration_OnAddTweaks(var _MobTweakContainer: Codeunit "MOB Tweak Container")
    var
    //Tweak: Text;
    begin
        _MobTweakContainer.Add(1000, 'Page: JobRegistration', NavApp.GetResourceAsText('JobRegistrationTweak.xml'));
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

        // Create German translation for my custom mobile message
        if _LanguageCode = 'DEU' then begin
            _Messages.Create('DEU', 'JobRegistration', 'Arbeitszeiterfassung');
            _Messages.Create('DEU', 'EmployeeNo', 'Mitarbeiternr.');
            _Messages.Create('DEU', 'JobNo', 'Auftragsnr.');
            _Messages.Create('DEU', 'ScanJobno', 'Auftragsnr. scannen');
            _Messages.Create('DEU', 'StopTime', 'Zeit stoppen');
            _Messages.Create('DEU', 'FinishJob', 'Auftrag beenden');
            _Messages.Create('DEU', 'FinishJobRegistration', 'Möchten Sie die Zeit stoppen/den Auftrag beenden?');
        end;

        // Create Spanish translation for my custom mobile message
        if _LanguageCode = 'ESP' then begin
            _Messages.Create('ESP', 'JobRegistration', 'Registro de trabajo');
            _Messages.Create('ESP', 'EmployeeNo', 'N.º de empleado');
            _Messages.Create('ESP', 'JobNo', 'N.º de trabajo');
            _Messages.Create('ESP', 'ScanJobno', 'Escanear n.º de trabajo');
            _Messages.Create('ESP', 'StopTime', 'Detener tiempo');
            _Messages.Create('ESP', 'FinishJob', 'Finalizar trabajo');
            _Messages.Create('ESP', 'FinishJobRegistration', '¿Desea detener el tiempo/finalizar el trabajo?');
        end;

        // Create Estonian translation for my custom mobile message
        if _LanguageCode = 'ETI' then begin
            _Messages.Create('ETI', 'JobRegistration', 'Töö registreerimine');
            _Messages.Create('ETI', 'EmployeeNo', 'Töötaja nr');
            _Messages.Create('ETI', 'JobNo', 'Töö nr');
            _Messages.Create('ETI', 'ScanJobno', 'Skanni töö nr');
            _Messages.Create('ETI', 'StopTime', 'Peata aeg');
            _Messages.Create('ETI', 'FinishJob', 'Lõpeta töö');
            _Messages.Create('ETI', 'FinishJobRegistration', 'Kas soovite aja peatada/töö lõpetada?');
        end;

        // Create Finnish translation for my custom mobile message
        if _LanguageCode = 'FIN' then begin
            _Messages.Create('FIN', 'JobRegistration', 'Työn rekisteröinti');
            _Messages.Create('FIN', 'EmployeeNo', 'Työntekijänro');
            _Messages.Create('FIN', 'JobNo', 'Työnro');
            _Messages.Create('FIN', 'ScanJobno', 'Skannaa työnro');
            _Messages.Create('FIN', 'StopTime', 'Pysäytä aika');
            _Messages.Create('FIN', 'FinishJob', 'Viimeistele työ');
            _Messages.Create('FIN', 'FinishJobRegistration', 'Haluatko pysäyttää ajan/viimeistellä työn?');
        end;

        // Create French translation for my custom mobile message
        if _LanguageCode = 'FRA' then begin
            _Messages.Create('FRA', 'JobRegistration', 'Enregistrement du travail');
            _Messages.Create('FRA', 'EmployeeNo', 'N° employé');
            _Messages.Create('FRA', 'JobNo', 'N° travail');
            _Messages.Create('FRA', 'ScanJobno', 'Scanner le n° de travail');
            _Messages.Create('FRA', 'StopTime', 'Arrêter le temps');
            _Messages.Create('FRA', 'FinishJob', 'Terminer le travail');
            _Messages.Create('FRA', 'FinishJobRegistration', 'Voulez-vous arrêter le temps/terminer le travail ?');
        end;

        // Create Croatian translation for my custom mobile message
        if _LanguageCode = 'HRV' then begin
            _Messages.Create('HRV', 'JobRegistration', 'Registracija posla');
            _Messages.Create('HRV', 'EmployeeNo', 'Br. zaposlenika');
            _Messages.Create('HRV', 'JobNo', 'Br. posla');
            _Messages.Create('HRV', 'ScanJobno', 'Skeniraj br. posla');
            _Messages.Create('HRV', 'StopTime', 'Zaustavi vrijeme');
            _Messages.Create('HRV', 'FinishJob', 'Završi posao');
            _Messages.Create('HRV', 'FinishJobRegistration', 'Želite li zaustaviti vrijeme/završiti posao?');
        end;

        // Create Italian translation for my custom mobile message
        if _LanguageCode = 'ITA' then begin
            _Messages.Create('ITA', 'JobRegistration', 'Registrazione commessa');
            _Messages.Create('ITA', 'EmployeeNo', 'N. dipendente');
            _Messages.Create('ITA', 'JobNo', 'N. commessa');
            _Messages.Create('ITA', 'ScanJobno', 'Scansiona n. commessa');
            _Messages.Create('ITA', 'StopTime', 'Arresta tempo');
            _Messages.Create('ITA', 'FinishJob', 'Completa commessa');
            _Messages.Create('ITA', 'FinishJobRegistration', 'Vuoi arrestare il tempo/completare la commessa?');
        end;

        // Create Japanese translation for my custom mobile message
        if _LanguageCode = 'JPN' then begin
            _Messages.Create('JPN', 'JobRegistration', 'ジョブ登録');
            _Messages.Create('JPN', 'EmployeeNo', '従業員番号');
            _Messages.Create('JPN', 'JobNo', 'ジョブ番号');
            _Messages.Create('JPN', 'ScanJobno', 'ジョブ番号をスキャン');
            _Messages.Create('JPN', 'StopTime', '時間を停止');
            _Messages.Create('JPN', 'FinishJob', 'ジョブを完了');
            _Messages.Create('JPN', 'FinishJobRegistration', '時間を停止してジョブを完了しますか？');
        end;

        // Create Lithuanian translation for my custom mobile message
        if _LanguageCode = 'LTH' then begin
            _Messages.Create('LTH', 'JobRegistration', 'Darbo registracija');
            _Messages.Create('LTH', 'EmployeeNo', 'Darbuotojo Nr.');
            _Messages.Create('LTH', 'JobNo', 'Darbo Nr.');
            _Messages.Create('LTH', 'ScanJobno', 'Nuskaityti darbo Nr.');
            _Messages.Create('LTH', 'StopTime', 'Sustabdyti laiką');
            _Messages.Create('LTH', 'FinishJob', 'Baigti darbą');
            _Messages.Create('LTH', 'FinishJobRegistration', 'Ar norite sustabdyti laiką / baigti darbą?');
        end;

        // Create Latvian translation for my custom mobile message
        if _LanguageCode = 'LVI' then begin
            _Messages.Create('LVI', 'JobRegistration', 'Darba reģistrācija');
            _Messages.Create('LVI', 'EmployeeNo', 'Darbinieka Nr.');
            _Messages.Create('LVI', 'JobNo', 'Darba Nr.');
            _Messages.Create('LVI', 'ScanJobno', 'Skenēt darba Nr.');
            _Messages.Create('LVI', 'StopTime', 'Apturēt laiku');
            _Messages.Create('LVI', 'FinishJob', 'Pabeigt darbu');
            _Messages.Create('LVI', 'FinishJobRegistration', 'Vai vēlaties apturēt laiku/pabeigt darbu?');
        end;

        // Create Dutch translation for my custom mobile message
        if _LanguageCode = 'NLD' then begin
            _Messages.Create('NLD', 'JobRegistration', 'Werkregistratie');
            _Messages.Create('NLD', 'EmployeeNo', 'Werknemernr.');
            _Messages.Create('NLD', 'JobNo', 'Jobnr.');
            _Messages.Create('NLD', 'ScanJobno', 'Scan jobnr.');
            _Messages.Create('NLD', 'StopTime', 'Tijd stoppen');
            _Messages.Create('NLD', 'FinishJob', 'Job voltooien');
            _Messages.Create('NLD', 'FinishJobRegistration', 'Wilt u de tijd stoppen/de job voltooien?');
        end;

        // Create Norwegian translation for my custom mobile message
        if _LanguageCode = 'NOR' then begin
            _Messages.Create('NOR', 'JobRegistration', 'Jobbregistrering');
            _Messages.Create('NOR', 'EmployeeNo', 'Ansattnr.');
            _Messages.Create('NOR', 'JobNo', 'Jobbnr.');
            _Messages.Create('NOR', 'ScanJobno', 'Skann jobbnr.');
            _Messages.Create('NOR', 'StopTime', 'Stopp tid');
            _Messages.Create('NOR', 'FinishJob', 'Fullfør jobb');
            _Messages.Create('NOR', 'FinishJobRegistration', 'Vil du stoppe tiden/fullføre jobben?');
        end;

        // Create Polish translation for my custom mobile message
        if _LanguageCode = 'PLK' then begin
            _Messages.Create('PLK', 'JobRegistration', 'Rejestracja zadania');
            _Messages.Create('PLK', 'EmployeeNo', 'Nr pracownika');
            _Messages.Create('PLK', 'JobNo', 'Nr zadania');
            _Messages.Create('PLK', 'ScanJobno', 'Zeskanuj nr zadania');
            _Messages.Create('PLK', 'StopTime', 'Zatrzymaj czas');
            _Messages.Create('PLK', 'FinishJob', 'Zakończ zadanie');
            _Messages.Create('PLK', 'FinishJobRegistration', 'Czy chcesz zatrzymać czas/zakończyć zadanie?');
        end;

        // Create Portuguese translation for my custom mobile message
        if _LanguageCode = 'PTG' then begin
            _Messages.Create('PTG', 'JobRegistration', 'Registo de trabalho');
            _Messages.Create('PTG', 'EmployeeNo', 'N.º funcionário');
            _Messages.Create('PTG', 'JobNo', 'N.º trabalho');
            _Messages.Create('PTG', 'ScanJobno', 'Digitalizar n.º trabalho');
            _Messages.Create('PTG', 'StopTime', 'Parar tempo');
            _Messages.Create('PTG', 'FinishJob', 'Concluir trabalho');
            _Messages.Create('PTG', 'FinishJobRegistration', 'Pretende parar o tempo/concluir o trabalho?');
        end;

        // Create Romanian translation for my custom mobile message
        if _LanguageCode = 'ROM' then begin
            _Messages.Create('ROM', 'JobRegistration', 'Înregistrare lucrare');
            _Messages.Create('ROM', 'EmployeeNo', 'Nr. angajat');
            _Messages.Create('ROM', 'JobNo', 'Nr. lucrare');
            _Messages.Create('ROM', 'ScanJobno', 'Scanați nr. lucrării');
            _Messages.Create('ROM', 'StopTime', 'Opriți timpul');
            _Messages.Create('ROM', 'FinishJob', 'Finalizați lucrarea');
            _Messages.Create('ROM', 'FinishJobRegistration', 'Doriți să opriți timpul/finalizați lucrarea?');
        end;

        // Create Russian translation for my custom mobile message
        if _LanguageCode = 'RUS' then begin
            _Messages.Create('RUS', 'JobRegistration', 'Регистрация задания');
            _Messages.Create('RUS', 'EmployeeNo', 'Номер сотрудника');
            _Messages.Create('RUS', 'JobNo', 'Номер задания');
            _Messages.Create('RUS', 'ScanJobno', 'Сканировать номер задания');
            _Messages.Create('RUS', 'StopTime', 'Остановить время');
            _Messages.Create('RUS', 'FinishJob', 'Завершить задание');
            _Messages.Create('RUS', 'FinishJobRegistration', 'Остановить время и завершить задание?');
        end;

        // Create Slovenian translation for my custom mobile message
        if _LanguageCode = 'SLV' then begin
            _Messages.Create('SLV', 'JobRegistration', 'Registracija opravila');
            _Messages.Create('SLV', 'EmployeeNo', 'Št. zaposlenega');
            _Messages.Create('SLV', 'JobNo', 'Št. opravila');
            _Messages.Create('SLV', 'ScanJobno', 'Skeniraj št. opravila');
            _Messages.Create('SLV', 'StopTime', 'Ustavi čas');
            _Messages.Create('SLV', 'FinishJob', 'Končaj opravilo');
            _Messages.Create('SLV', 'FinishJobRegistration', 'Ali želite ustaviti čas/končati opravilo?');
        end;

        // Create Swedish translation for my custom mobile message
        if _LanguageCode = 'SVE' then begin
            _Messages.Create('SVE', 'JobRegistration', 'Jobbregistrering');
            _Messages.Create('SVE', 'EmployeeNo', 'Anställningsnr.');
            _Messages.Create('SVE', 'JobNo', 'Jobbnr.');
            _Messages.Create('SVE', 'ScanJobno', 'Skanna jobbnummer');
            _Messages.Create('SVE', 'StopTime', 'Stoppa tid');
            _Messages.Create('SVE', 'FinishJob', 'Slutför jobb');
            _Messages.Create('SVE', 'FinishJobRegistration', 'Vill du stoppa tiden/slutföra jobbet?');
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