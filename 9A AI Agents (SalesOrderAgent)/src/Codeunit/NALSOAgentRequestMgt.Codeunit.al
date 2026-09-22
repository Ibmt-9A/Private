// Builds the structured task message text sent to the NAL Sales Order Agent from a manually entered order request.
codeunit 50105 NALSOAgentRequestMgt
{
    Access = Internal;

    procedure BuildTaskMessage(var TempNALSOAgentRequestLine: Record NALSOAgentRequestLine temporary): Text
    var
        MessageBuilder: TextBuilder;
        CustomerNo: Code[20];
    begin
        if TempNALSOAgentRequestLine.IsEmpty() then
            Error(NoLinesErr);

        TempNALSOAgentRequestLine.FindSet();
        CustomerNo := TempNALSOAgentRequestLine."Customer No.";
        repeat
            if TempNALSOAgentRequestLine."Customer No." <> CustomerNo then
                Error(OneCustomerOnlyErr);
            if TempNALSOAgentRequestLine."Item No." = '' then
                Error(ItemRequiredErr, TempNALSOAgentRequestLine."Line No.");
            if TempNALSOAgentRequestLine.Quantity = 0 then
                Error(QuantityRequiredErr, TempNALSOAgentRequestLine."Line No.");
        until TempNALSOAgentRequestLine.Next() = 0;

        MessageBuilder.AppendLine(StrSubstNo(CustomerLineLbl, CustomerNo));
        TempNALSOAgentRequestLine.FindSet();
        repeat
            MessageBuilder.AppendLine(
                StrSubstNo(
                    RequestLineLbl,
                    TempNALSOAgentRequestLine."Item No.",
                    TempNALSOAgentRequestLine.Quantity,
                    TempNALSOAgentRequestLine."Requested Delivery Date"));
        until TempNALSOAgentRequestLine.Next() = 0;

        exit(MessageBuilder.ToText());
    end;

    var
        NoLinesErr: Label 'Enter at least one order line before sending the request to the agent.';
        OneCustomerOnlyErr: Label 'All lines must use the same Customer No. Split requests for different customers into separate tasks.';
        ItemRequiredErr: Label 'Line %1 is missing an Item No.', Comment = '%1 = Line No.';
        QuantityRequiredErr: Label 'Line %1 must have a Quantity greater than 0.', Comment = '%1 = Line No.';
        CustomerLineLbl: Label 'Customer No.: %1', Locked = true, Comment = '%1 = Customer No.';
        RequestLineLbl: Label 'Line: Item No. %1, Quantity %2, Requested Delivery Date %3', Locked = true, Comment = '%1 = Item No., %2 = Quantity, %3 = Requested Delivery Date';
}
