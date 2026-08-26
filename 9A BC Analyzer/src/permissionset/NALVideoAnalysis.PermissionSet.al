permissionset 51000 NALVideoAnalysis
{
    Caption = 'Video Analysis - Full Access';
    Assignable = true;

    Permissions =
        tabledata NALVideoAnalysisSetup = RIMD,
        tabledata NALVideoAnalysis = RIMD,
        tabledata NALVideoAnalysisLine = RIMD,
        table NALVideoAnalysisSetup = X,
        table NALVideoAnalysis = X,
        table NALVideoAnalysisLine = X,
        codeunit NALVideoAnalysisMgt = X,
        page NALVideoAnalysisSetup = X,
        page NALVideoAnalysisList = X,
        page NALVideoAnalysisCard = X,
        page NALVideoAnalysisLines = X,
        report NALVideoAnalysisReport = X;
}
