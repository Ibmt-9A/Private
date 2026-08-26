page 51002 NALVideoAnalysisCard
{
    Caption = 'Video Analysis';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = None;
    SourceTable = NALVideoAnalysis;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(FileName; Rec.FileName)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                    StyleExpr = StatusStyle;
                }
                field(VideoSizeKB; Rec.VideoSizeKB)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(AnalysisDate; Rec.AnalysisDate)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(CreatedBy; Rec.CreatedBy)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                }
                field(CreatedAt; Rec.CreatedAt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                }
            }
            group(TokenUsage)
            {
                Caption = 'Token Usage';
                Visible = Rec.Status = Rec.Status::Completed;

                field(PromptTokens; Rec.PromptTokens)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(CompletionTokens; Rec.CompletionTokens)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            group(ErrorGroup)
            {
                Caption = 'Error Information';
                Visible = Rec.Status = Rec.Status::Error;

                field(ErrorMessage; Rec.ErrorMessage)
                {
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                    StyleExpr = 'Unfavorable';
                }
            }
            part(AnalysisLines; NALVideoAnalysisLines)
            {
                ApplicationArea = All;
                Caption = 'Analysis Result';
                SubPageLink = EntryNo = field(EntryNo);
                Visible = Rec.Status = Rec.Status::Completed;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UploadVideo)
            {
                Caption = 'Upload Video';
                ApplicationArea = All;
                Image = Import;
                ToolTip = 'Upload an MP4 screen recording from Business Central.';
                Enabled = Rec.Status <> Rec.Status::Processing;

                trigger OnAction()
                var
                    VideoAnalysisMgt: Codeunit NALVideoAnalysisMgt;
                begin
                    VideoAnalysisMgt.ImportVideoFile(Rec);
                    HasVideoFile := Rec.HasVideo();
                    CurrPage.Update(false);
                end;
            }
            action(AnalyzeVideo)
            {
                Caption = 'Analyze Video';
                ApplicationArea = All;
                Image = Process;
                ToolTip = 'Start AI analysis of the uploaded video using Azure OpenAI.';
                Enabled = HasVideoFile and (Rec.Status <> Rec.Status::Processing);

                trigger OnAction()
                var
                    VideoAnalysisMgt: Codeunit NALVideoAnalysisMgt;
                begin
                    VideoAnalysisMgt.AnalyzeVideo(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(DownloadHTML)
            {
                Caption = 'Download HTML Report';
                ApplicationArea = All;
                Image = ExportFile;
                ToolTip = 'Download the full analysis as an HTML file. Open in a browser to print as PDF.';
                Enabled = Rec.Status = Rec.Status::Completed;

                trigger OnAction()
                var
                    VideoAnalysisMgt: Codeunit NALVideoAnalysisMgt;
                begin
                    VideoAnalysisMgt.DownloadHTMLReport(Rec);
                end;
            }
            action(PrintReport)
            {
                Caption = 'Print / PDF Report';
                ApplicationArea = All;
                Image = Print;
                ToolTip = 'Print or export the analysis as a PDF report.';
                Enabled = Rec.Status = Rec.Status::Completed;

                trigger OnAction()
                var
                    VideoAnalysis: Record NALVideoAnalysis;
                begin
                    VideoAnalysis.SetRange(EntryNo, Rec.EntryNo);
                    Report.RunModal(51000, true, false, VideoAnalysis);
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
            actionref(UploadVideo_Promoted; UploadVideo) { }
            actionref(AnalyzeVideo_Promoted; AnalyzeVideo) { }
            actionref(DownloadHTML_Promoted; DownloadHTML) { }
            actionref(PrintReport_Promoted; PrintReport) { }
        }
    }

    var
        StatusStyle: Text;
        HasVideoFile: Boolean;

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
        HasVideoFile := Rec.HasVideo();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        StatusStyle := 'Standard';
        HasVideoFile := false;
    end;

    local procedure SetStatusStyle()
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
