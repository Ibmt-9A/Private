page 51003 NALVideoAnalysisLines
{
    Caption = 'Analysis Lines';
    PageType = ListPart;
    ApplicationArea = All;
    SourceTable = NALVideoAnalysisLine;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(LineNo; Rec.LineNo)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(LineType; Rec.LineType)
                {
                    ApplicationArea = All;
                    StyleExpr = LineTypeStyle;
                    Width = 10;
                }
                field(SequenceTime; Rec.SequenceTime)
                {
                    ApplicationArea = All;
                    Width = 10;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    var
        LineTypeStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.LineType of
            Rec.LineType::SceneChange:
                LineTypeStyle := 'Strong';
            else
                LineTypeStyle := 'Standard';
        end;
    end;
}
