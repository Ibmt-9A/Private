report 51000 NALVideoAnalysisReport
{
    Caption = 'Video Analysis Report';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = 'src/report/NALVideoAnalysisReport.rdlc';

    dataset
    {
        dataitem(VideoAnalysis; NALVideoAnalysis)
        {
            column(EntryNo; EntryNo) { }
            column(Description; Description) { }
            column(FileName; FileName) { }
            column(StatusText; Format(Status)) { }
            column(AnalysisDate; Format(AnalysisDate)) { }
            column(VideoSizeMB; VideoSizeKB div 1024) { }
            column(CreatedBy; CreatedBy) { }
            column(CompanyName; CompanyName()) { }
            column(ReportTitle; ReportTitleLbl) { }
            column(FileNameLbl; FileNameLbl) { }
            column(StatusLbl; StatusLbl) { }
            column(AnalysisDateLbl; AnalysisDateLbl) { }
            column(VideoSizeLbl; VideoSizeLbl) { }
            column(CreatedByLbl; CreatedByLbl) { }

            dataitem(VideoAnalysisLine; NALVideoAnalysisLine)
            {
                DataItemLink = EntryNo = field(EntryNo);
                DataItemTableView = sorting(EntryNo, LineNo);

                column(LineNo; LineNo) { }
                column(LineTypeText; Format(LineType)) { }
                column(IsSceneChange; LineType = LineType::SceneChange) { }
                column(LineDescription; Description) { }
                column(SequenceTime; SequenceTime) { }
            }
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                }
            }
        }
    }

    var
        ReportTitleLbl: Label 'BC Video Analysis Report';
        FileNameLbl: Label 'File Name';
        StatusLbl: Label 'Status';
        AnalysisDateLbl: Label 'Analysis Date';
        VideoSizeLbl: Label 'Video Size (MB)';
        CreatedByLbl: Label 'Created By';
}
