codeunit 50100 TaskletSubscriber
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB Application Configuration", 'OnGetApplicationConfiguration_OnAddTweaks', '', true, true)]
    local procedure OnGetApplicationConfiguration_OnAddTweaks(var _MobTweakContainer: Codeunit "MOB Tweak Container")
    var
        Tweak: Text;
    begin
        Clear(Tweak);
        //MyUnplanned page - add new unplanned item registration page
        Tweak :=
            '<?xml version="1.0" encoding="utf-8"?>' +
            '<application xmlns="http://schemas.taskletfactory.com/MobileWMS/Application" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://schemas.taskletfactory.com/MobileWMS/Application http://schemas.taskletfactory.com/MobileWMS/Application.xsd">' +
            '  <pages>' +
            '    <page id="MyUnplanned" type="UnplannedItemRegistration" icon="mainmenusettings" tweak="Append">' +
            '      <title defaultValue="@{MY_UNPLANNED_1_TITLE}" />' +
            '      <unplannedItemRegistrationConfiguration type="MyUnplanned" useRegistrationCollector="true">' +
            '        <header configurationKey="MyUnplanned" automaticAcceptOnOpen="false" clearAfterPost="true" />' +
            '      </unplannedItemRegistrationConfiguration>' +
            '    </page>' +
            '    <page id="MainMenu">' +
            '      <menuConfiguration>' +
            '        <menuItems>' +
            '          <menuItem id="MyUnplanned" displayName="@{MY_UNPLANNED_1_MENU}" icon="mainmenusettings" tweak="Append" />' +
            '        </menuItems>' +
            '      </menuConfiguration>' +
            '    </page>' +
            '  </pages>' +
            '</application>';
        _MobTweakContainer.Add(1000, 'Page: MyUnplanned', Tweak);
    end;

    // Step 2: Define Header and headerFields
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Reference Data", 'OnGetReferenceData_OnAddHeaderConfigurations', '', true, true)]
    local procedure MyGetReferenceData_OnAddHeaderConfigurations(var _HeaderFields: Record "MOB HeaderField Element")
    begin
        _HeaderFields.InitConfigurationKey('MyUnplanned'); // Identifier for new Header - replace by your own name

        // Add Header fields here
        _HeaderFields.Create_DateField(10, 'MyDate', 'Select date');

        _HeaderFields.Create_TextField(20, 'MyText', 'Enter text');
        _HeaderFields.Set_optional(true);

        _HeaderFields.Create_DecimalField(30, 'MyDecimal', 'Enter decimal');
    end;

    // Step 3: Define Steps (optional)
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

        // Read _RequestValues
        MyDate := _RequestValues.GetValueAsDate('MyDateStep');
        MyText := _RequestValues.GetValue('MyTextStep');
        MyDecimal := _RequestValues.GetValueAsDecimal('MyDecimalStep');

        _SuccessMessage := StrSubstNo('Success %1 %2 %3', MyDate, MyText, MyDecimal);
        _RegistrationTypeTracking := 'Tracking info for the Document queue.';

        _IsHandled := true;
    end;

    /*
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Receive", 'OnGetReceiveOrderLines_OnAddStepsToAnyHeader', '', false, false)]
    local procedure "MOB WMS Receive_OnGetReceiveOrderLines_OnAddStepsToAnyHeader"(_RecRef: RecordRef; var _StepsElement: Record "MOB Steps Element")
    begin
        AddMyPostingDateStep(_StepsElement);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB WMS Receive", 'OnPostReceiveOrder_OnBeforePostPurchaseOrder', '', false, false)]
    local procedure "MOB WMS Receive_OnPostReceiveOrder_OnBeforePostPurchaseOrder"(var _OrderValues: Record "MOB Common Element"; var _PurchHeader: Record "Purchase Header")
    var
        TempOrderValues: Record "MOB Common Element" temporary;
        MobRequestMgt: Codeunit "MOB NS Request Management";
        MyPostingDate: Date;
    begin
        MyPostingDate := _OrderValues.GetValueAsDate('MyPostingDateStep', false);
        // MobRequestMgt.GetOrderValues(_OrderValues.SystemId, TempOrderValues);
        // MyPostingDate := TempOrderValues.GetValueAsDate('MyPostingDateStep', false);

        if MyPostingDate <> 0D then
            _PurchHeader.Validate("Posting Date", MyPostingDate);

        _PurchHeader."Assigned User ID" := CopyStr(UserId(), 1, MaxStrLen(_PurchHeader."Assigned User ID"));
    end;

    local procedure AddMyPostingDateStep(var _Steps: Record "MOB Steps Element")
    begin
        _Steps.Create_DateStep(10000, 'MyPostingDateStep');
        _Steps.Set_header('Posting Date');
        _Steps.Set_defaultValue(Today());
        // _Steps.Set_minDate(Today() - 1);
        // _Steps.Set_maxDate(Today());
    end;
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"MOB Application Configuration", 'OnGetApplicationConfiguration_OnAddTweaks', '', true, true)]
    local procedure OnGetApplicationConfiguration_OnAddTweaks(var _MobTweakContainer: Codeunit "MOB Tweak Container")
    var
        Tweak: Text;
    begin
        Clear(Tweak);
        //ReceiveLines action menu - add new action
        Tweak := @'<?xml version="1.0" encoding="utf-8"?>
                    <application>
                      <pages>
                        <page id="ReceiveLines" type="OrderLines" icon="mainmenureceive">
                          <actions>
                            <!-- Custom -->
                            <open icon="mainmenuprint" id="MyUnplanned2" title="Necas print" tweak="Append">
                              <returnTransfer property="UnplannedItemRegistrationCompleted" to="RefreshOnResume"/>
                            </open>
                            <!-- Custom --> 
                          </actions>
                        </page>
                      </pages>
                    </application>';
        _MobTweakContainer.Add(1000, 'Page: ReceiveLines_Actionmenu', Tweak);

        //Production Consumption action menu - add new action
        Clear(Tweak);
        Tweak := @'<?xml version="1.0" encoding="utf-8"?>
                <application>
                <pages>
                    <page id="ProdConsumptionLines" type="OrderLines" icon="productionConsumption">
                        <actions>
                        <!-- Custom -->
                        <open id="ItemLedger" icon="mainmenulocateitem" title="Item Ledger"  tweak="Append"/>
                        <!-- Custom --> 
                        </actions>
                    </page>
                </pages>
                </application>';
        _MobTweakContainer.Add(2000, 'Page: ProdConsumptionLines_Actionmenu', Tweak);

        //Item Ledger lookup page - create new lookup page
        Clear(Tweak);
        Tweak := @'<?xml version="1.0" encoding="utf-8"?>
                <application>
                    <pages>        
                        <page id="ItemLedger" type="Lookup" icon="stopwatch" tweak="Append">
                        <title defaultValue="Item Ledger"/>
                        <lookupConfiguration type="ItemLedger" useRegistrationCollector="false">
                            <header configurationKey="ItemLedgerHeader" automaticAcceptOnOpen="true" hideAfterAccept="true"/>
                            <onResultSelected enabled="true" navigateTo="null"/>
                            <list listId="LookupItemLedger"/>
                        </lookupConfiguration>
                        </page>
                    </pages>
                </application>';
        _MobTweakContainer.Add(3000, 'Page: ItemLedger_Actionmenu', Tweak);

        Tweak := @'<?xml version="1.0" encoding="utf-8"?>
                <application>
                  <resources theme="Tasklet">
                    <lists useSingleSelectionDefault="false">
                      <listConfiguration id="LookupItemLedger" tweak="append">
                        <columns>
                            <column width="65" xAlign="left" yAlign="top">
                                <elements>
                                    <textElement fontId="headlineFont" text="{DisplayLine1}"/>
                                    <textElement fontId="contentFont" text="{DisplayLine2}"/>
                                    <textElement fontId="contentFont" text="{DisplayLine3}"/>
                                    <textElement fontId="contentFont" text="{DisplayLine4}"/>
                                    <textElement fontId="contentFont" text="{DisplayLine5}"/>
                                    <textElement fontId="contentFont" text="{DisplayLotNumber} {DisplaySerialNumber} {DisplayExpirationDate}" dataMember="DisplayTrackingFeatureIsEnabled">
                                    <values>
                                    <value if="equals" dataMemberValue="true" text="{DisplayTracking} {DisplayExpirationDate}"/>
                                    </values>
                                    </textElement>
                                </elements>
                            </column>
                            <column width="35" xAlign="right" yAlign="top">
                                <elements>
                                    <textElement fontId="headlineFont" text="{Quantity}" horizontalAlignment="right"/>
                                </elements>
                            </column>
                         </columns>
                      </listConfiguration>
                    </lists>
                  </resources>
                </application>';
        _MobTweakContainer.Add(4000, 'ItemLeder list', Tweak);

        //MyUnplanned2 action menu - add new action
        Clear(Tweak);
        Tweak := @'<?xml version="1.0" encoding="utf-8"?>
                <application>
                    <pages>        
                        <page id="MyUnplanned2" type="UnplannedItemRegistration" tweak="Append">
                        <title defaultValue="Labels to print"/>
                        <unplannedItemRegistrationConfiguration type="MyUnplanned2" useRegistrationCollector="true">
                            <header configurationKey="LabelFilters" automaticAcceptOnOpen="true"/>
                        </unplannedItemRegistrationConfiguration>
                        </page>
                    </pages>
                </application>';
        _MobTweakContainer.Add(5000, 'Page: MyUnplanned2_Actionmenu', Tweak);

        //Registration Collector - auto forward after lot number scan - disable auto forward
        Tweak := @'<?xml version="1.0" encoding="utf-8"?>
                <application>
                    <resources theme="Tasklet">
                        <workflows>
                            <workflow id="standard" tweak="Replace" itemNumberAI="01,02,91">
                                <configuration scanBehaviourWhenRegisteringQuantity="ValidateCurrentItem">
                                    <steps>
                                        <fromBin id="10" header="@{RegistrationCollectorFromBinHeader}" label="{FromBin}" defaultValue="{FromBin}" helpLabel="@{RegistrationCollectorFromBinHelpLabel}" eanAi="00" autoForwardAfterScan="false"/>
                                        <toBin id="20" header="@{RegistrationCollectorToBinHeader}" label="{ToBin}" defaultValue="{ToBin}" helpLabel="@{RegistrationCollectorToBinHelpLabel}" eanAi="00" autoForwardAfterScan="false"/>
                                        <expirationDate id="31" header="@{RegistrationCollectorExpirationDateHeader}" label="" defaultValue="{ExpirationDate}" helpLabel="@{RegistrationCollectorExpirationDateHelpLabel}" eanAi="15,17,12"/>
                                        <lotNumber id="32" header="@{RegistrationCollectorLotNumberHeader}" defaultValue="{LotNumber}" helpLabel="@{RegistrationCollectorLotNumberHelpLabel}" eanAi="10" autoForwardAfterScan="false"/>
                                        <tote id="35" header="@{RegistrationCollectorToteHeader}" helpLabel="@{RegistrationCollectorToteHelpLabel}" eanAi="98"/>
                                        <!-- id="37" reserved for PackageNumber -->
                                        <serialNumber id="40" header="@{RegistrationCollectorSerialNumberHeader}" defaultValue="{SerialNumber}" helpLabel="@{RegistrationCollectorSerialNumberHelpLabel}" eanAi="21"/>
                                        <quantity id="50" header="@{RegistrationCollectorQuantityHeader}" helpLabel="@{RegistrationCollectorQuantityHelpLabel}" eanAi="310,30,37" minValue="0.0000000001" autoForwardAfterScan="false"/>
                                        <quantityByScan id="51" header="@{RegistrationCollectorQuantityByScanHeader}" helpLabel="@{RegistrationCollectorQuantityByScanHelpLabel}" minValue="0.0000000001" autoForwardAfterScan="false"/>
                                    </steps>
                                </configuration>
                            </workflow>
                        </workflows>
                    </resources>
                </application>';
        _MobTweakContainer.Add(6000, 'workflows: Standard_LotNumber_autoForwardAfterScan', Tweak);

        //Registration Collector - auto forward after lot number scan - disable auto forward
        Tweak := @'<?xml version="1.0" encoding="utf-8"?>
                <application>
                    <resources theme="Tasklet">
                        <workflows>
                            <workflow id="productionWorkflow" tweak="Replace" itemNumberAI="01,02,91">
                                <configuration scanBehaviourWhenRegisteringQuantity="ValidateCurrentItem">
                                <steps>
                                    <fromBin id="10" header="@{RegistrationCollectorFromBinHeader}" label="{FromBin}" defaultValue="{FromBin}" helpLabel="@{RegistrationCollectorFromBinHelpLabel}" eanAi="00" autoForwardAfterScan="false"/>
                                    <toBin id="20" header="@{RegistrationCollectorToBinHeader}" label="{ToBin}" defaultValue="{ToBin}" helpLabel="@{RegistrationCollectorToBinHelpLabel}" eanAi="00" autoForwardAfterScan="false"/>
                                    <expirationDate id="31" header="@{RegistrationCollectorExpirationDateHeader}" label="" helpLabel="@{RegistrationCollectorExpirationDateHelpLabel}" eanAi="15,17,12"/>
                                    <lotNumber id="32" header="@{RegistrationCollectorLotNumberHeader}" defaultValue="{LotNumber}" helpLabel="@{RegistrationCollectorLotNumberHelpLabel}" eanAi="10" autoForwardAfterScan="false"/>
                                    <tote id="35" header="@{RegistrationCollectorToteHeader}" helpLabel="@{RegistrationCollectorToteHelpLabel}" eanAi="98"/>
                                    <!-- id="37" reserved for PackageNumber -->
                                    <serialNumber id="40" header="@{RegistrationCollectorSerialNumberHeader}" defaultValue="{SerialNumber}" helpLabel="@{RegistrationCollectorSerialNumberHelpLabel}" eanAi="21"/>
                                    <quantity id="50" header="@{RegistrationCollectorQuantityHeader}" helpLabel="@{RegistrationCollectorQuantityHelpLabel}" eanAi="310,30,37" minValue="-99999999999" autoForwardAfterScan="false"/>
                                    <quantityByScan id="51" header="@{RegistrationCollectorQuantityByScanHeader}" helpLabel="@{RegistrationCollectorQuantityByScanHelpLabel}" minValue="0.0000000001" autoForwardAfterScan="false"/>
                                </steps>
                                </configuration>
                            </workflow>
                        </workflows>
                    </resources>
                </application>';
        _MobTweakContainer.Add(7000, 'workflows: Production_LotNumber_autoForwardAfterScan', Tweak);
    end;
    */
}