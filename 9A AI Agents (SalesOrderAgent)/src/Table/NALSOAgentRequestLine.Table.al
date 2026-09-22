// Temporary buffer used on the NAL Sales Order Agent Request page to capture a structured order request before it's sent to the agent.
table 50102 NALSOAgentRequestLine
{
    Access = Internal;
    Caption = 'NAL Sales Order Agent Request Line';
    DataClassification = CustomerContent;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
            ToolTip = 'Specifies the line number.';
        }
        field(10; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            ToolTip = 'Specifies the customer the order request is for. Use the same customer on every line.';
            TableRelation = Customer;

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                if Customer.Get("Customer No.") then
                    "Customer Name" := Customer.Name
                else
                    "Customer Name" := '';
            end;
        }
        field(11; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            ToolTip = 'Specifies the name of the customer.';
            Editable = false;
        }
        field(20; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            ToolTip = 'Specifies the requested item.';
            TableRelation = Item;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if Item.Get("Item No.") then
                    Description := Item.Description
                else
                    Description := '';
            end;
        }
        field(21; Description; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Specifies the description of the item.';
            Editable = false;
        }
        field(30; Quantity; Decimal)
        {
            Caption = 'Quantity';
            ToolTip = 'Specifies the requested quantity.';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(40; "Requested Delivery Date"; Date)
        {
            Caption = 'Requested Delivery Date';
            ToolTip = 'Specifies the delivery date requested by the customer.';
        }
    }
    keys
    {
        key(Key1; "Line No.")
        {
            Clustered = true;
        }
    }
}
