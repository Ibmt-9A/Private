page 51001 NALVideoAnalysisList
{
    Caption = 'Video Analyses';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = NALVideoAnalysis;
    CardPageId = NALVideoAnalysisCard;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(FileName; Rec.FileName)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyle;
                }
                field(AnalysisDate; Rec.AnalysisDate)
                {
                    ApplicationArea = All;
                }
                field(VideoSizeKB; Rec.VideoSizeKB)
                {
                    ApplicationArea = All;
                }
                field(CreatedBy; Rec.CreatedBy)
                {
                    ApplicationArea = All;
                }
                field(CreatedAt; Rec.CreatedAt)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewAnalysis)
            {
                Caption = 'New Analysis';
                ApplicationArea = All;
                Image = New;
                RunObject = page NALVideoAnalysisCard;
                RunPageMode = Create;
                ToolTip = 'Create a new video analysis entry.';
            }
            action(AnalyzeVideo)
            {
                Caption = 'Analyze Video';
                ApplicationArea = All;
                Image = Process;
                ToolTip = 'Start AI analysis of the uploaded video.';
                Enabled = Rec.Status <> Rec.Status::Processing;

                trigger OnAction()
                var
                    VideoAnalysisMgt: Codeunit NALVideoAnalysisMgt;
                begin
                    VideoAnalysisMgt.AnalyzeVideo(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(DownloadReport)
            {
                Caption = 'Download HTML Report';
                ApplicationArea = All;
                Image = ExportFile;
                ToolTip = 'Download the analysis as an HTML report with text and scene markers.';
                Enabled = Rec.Status = Rec.Status::Completed;

                trigger OnAction()
                var
                    VideoAnalysisMgt: Codeunit NALVideoAnalysisMgt;
                begin
                    VideoAnalysisMgt.DownloadHTMLReport(Rec);
                end;
            }
        }
        area(Navigation)
        {
            action(Setup)
            {
                Caption = 'Setup';
                ApplicationArea = All;
                Image = Setup;
                RunObject = page NALVideoAnalysisSetup;
                ToolTip = 'Open Video Analysis Setup to configure Azure OpenAI connection.';
            }
        }
        area(Promoted)
        {
            actionref(NewAnalysis_Promoted; NewAnalysis) { }
            actionref(AnalyzeVideo_Promoted; AnalyzeVideo) { }
            actionref(DownloadReport_Promoted; DownloadReport) { }
        }
    }

    var
        StatusStyle: Text;

    trigger OnAfterGetRecord()
    begin
        case Rec.Status of
            Rec.Status::Completed:
                StatusStyle := 'Favorable';
            Rec.Status::Error:
                StatusStyle := 'Unfavorable';
            Rec.Status::Processing:
                StatusStyle := 'Ambiguous';
            else
                StatusStyle := 'Standard';
        end;
    end;
}
