codeunit 50100 TaskletSubscriber
{

    //New Line Step Pick

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Pick", 'OnGetPickOrderLines_OnAddStepsToAnyLine', '', true, true)]
    local procedure OnGetPickOrderLines_OnAddStepsToAnyLine(_RecRef: RecordRef; var _BaseOrderLineElement: Record "MOB Ns BaseDataModel Element"; var _Steps: Record "MOB Steps Element")
    begin
        _Steps.Create_TextStep(10, 'MyTextStep', 'Header text', 'Label text', 'Help text', 'Default text', 30);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Pick", 'OnPostPickOrder_OnHandleRegistrationForAnyLine', '', true, true)]
    local procedure OnPostPickOrder_OnHandleRegistrationForAnyLine(var _Registration: Record "MOB WMS Registration"; var _RecRef: RecordRef)
    var
        SalesLine: Record "Sales Line";
        MyTextValue: Text;
        RecID: RecordId;
    begin
        MyTextValue := _Registration.GetValue('MyTextStep');

        if MyTextValue = '' then
            exit;

        // Get the source document line as this event if for "Any line". Choose a more specific event if you only need to handle one document type 
        if _Registration."Source Type" = Database::"Sales Line" then begin
            SalesLine.Reset();
            SalesLine.SetRange("Document Type", _RecRef.Field(5).Value);
            SalesLine.SetRange("Document No.", _RecRef.Field(6).Value);
            SalesLine.SetRange("Line No.", _RecRef.Field(7).Value);
            IF SalesLine.findset then begin
                AddAsCommentLine(SalesLine, 'FromMobile', CopyStr(MyTextValue, 1, 80));
            end;
        end;

        Error('NAL');
        // Note: You might also need to subscribe to Standard Posting Routines to process your new data
    end;

    local procedure AddAsCommentLine(_SalesLine: Record "Sales Line"; _Code: Code[10]; _Comment: Text[80])
    var
        SalesCommmentLine: Record "Sales Comment Line";
        NextLineNo: Integer;
    begin
        // Find next LineNo
        SalesCommmentLine.SetRange("Document Type", _SalesLine."Document Type");
        SalesCommmentLine.SetRange("No.", _SalesLine."Document No.");
        if SalesCommmentLine.FindLast() then
            NextLineNo := SalesCommmentLine."Line No." + 10000
        else
            NextLineNo := 10000;

        // Init and insert the comment line
        SalesCommmentLine.Init();
        SalesCommmentLine."Document Type" := _SalesLine."Document Type";
        SalesCommmentLine."No." := _SalesLine."Document No.";
        SalesCommmentLine."Document Line No." := _SalesLine."Line No.";
        SalesCommmentLine.Code := _Code;
        SalesCommmentLine."Line No." := NextLineNo;
        SalesCommmentLine.Date := Today();
        SalesCommmentLine.Comment := _Comment;
        SalesCommmentLine.Insert();
    end;


    //New Unplanne Move

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Reference Data", 'OnGetReferenceData_OnAddHeaderConfigurations', '', true, true)]
    local procedure MyGetReferenceData_OnAddHeaderConfigurations(var _HeaderFields: Record "MOB HeaderField Element")
    begin
        _HeaderFields.InitConfigurationKey('MyHeader'); // Identifier for new Header - replace by your own name

        // Add Header fields here
        _HeaderFields.Create_DateField(10, 'MyDate', 'Select date');

        _HeaderFields.Create_TextField(20, 'MyText', 'Enter text');
        _HeaderFields.Set_optional(true);

        _HeaderFields.Create_DecimalField(30, 'MyDecimal', 'Enter decimal');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Adhoc Registr.", 'OnGetRegistrationConfiguration_OnAddSteps', '', true, true)]
    local procedure MyOnGetRegistrationConfiguration_OnAddSteps(_RegistrationType: Text; var _HeaderFieldValues: Record "MOB NS Request Element"; var _Steps: Record "MOB Steps Element"; var _RegistrationTypeTracking: Text)
    var
        MyDate: Date;
        MyText: Text;
        MyDecimal: Decimal;
    begin
        // Handle only your own Header name
        if _RegistrationType <> 'MyUnplanned' then
            exit;

        // Read the headerFields
        MyDate := _HeaderFieldValues.GetValueAsDate('MyDate');
        MyText := _HeaderFieldValues.GetValue('MyText');
        MyDecimal := _HeaderFieldValues.GetValueAsDecimal('MyDecimal');

        // Add steps
        // For illustration, re-use the headerField value as default values on the steps
        _Steps.Create_DateStep(10, 'MyDateStep');
        _Steps.Set_header('MyDateStep');
        _Steps.Set_defaultValue(MyDate);

        _Steps.Create_TextStep(20, 'MyTextStep');
        _Steps.Set_defaultValue(MyText);
        _Steps.Set_header('MyTextStep');

        _Steps.Create_DecimalStep(30, 'MyDecimalStep');
        _Steps.Set_defaultValue(MyDecimal);
        _Steps.Set_header('MyDecimalStep');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Adhoc Registr.", 'OnPostAdhocRegistrationOnCustomRegistrationType', '', true, true)]
    local procedure MyOnPostAdhocRegistrationOnCustomRegistrationType(_RegistrationType: Text; var _RequestValues: Record "MOB NS Request Element"; var _CurrentRegistrations: Record "MOB WMS Registration"; var _SuccessMessage: Text; var _RegistrationTypeTracking: Text; var _IsHandled: Boolean)
    var
        MyDate: Date;
        MyText: Text;
        MyDecimal: Decimal;
    begin
        if _RegistrationType <> 'MyUnplanned' then
            exit;

        if _IsHandled then
            exit;

        // Read _RequestValues
        MyDate := _RequestValues.GetValueAsDate('MyDateStep');
        MyText := _RequestValues.GetValue('MyTextStep');
        MyDecimal := _RequestValues.GetValueAsDecimal('MyDecimalStep');

        _SuccessMessage := StrSubstNo('Success %1 %2 %3', MyDate, MyText, MyDecimal);
        _RegistrationTypeTracking := 'Tracking info for the Document queue.';

        _IsHandled := true;
    end;
}