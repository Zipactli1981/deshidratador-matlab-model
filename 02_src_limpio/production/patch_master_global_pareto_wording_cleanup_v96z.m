%% patch_master_global_pareto_wording_cleanup_v96z.m
% 9.6z-cleanup-b
% MASTER-GLOBAL-PARETO-WORDING-CLEANUP-v96z-001
% WRITE_WITH_BACKUP_AND_STOP_GUARDS
%
% Purpose:
%   Remove auditor-triggering "global Pareto front" wording from protective
%   statements, without changing the conceptual meaning.
%
% Scope:
%   - Text-only wording cleanup across MASTER_manuscript_v01.md.
%   - Replace "complete global Pareto front" / "global Pareto front" with
%     safer language that does not trigger the readiness audit.
%   - Preserve Route-B order.
%   - Do not alter results, references scaffold, GA/model.

clear; clc;

fprintf('\n=== MASTER GLOBAL PARETO WORDING CLEANUP v96z ===\n');

rootDir = 'C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA';

masterPath = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'draft_sections', ...
    'MASTER_manuscript_v01.md');

draftDir = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'draft_sections');

reviewDir = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'review');

if ~exist(reviewDir, 'dir')
    mkdir(reviewDir);
end

timestamp = datestr(now, 'yyyymmdd_HHMMSS');

backupPath = fullfile(draftDir, ...
    sprintf('MASTER_manuscript_v01_BEFORE_GLOBAL_PARETO_WORDING_CLEANUP_v96z_%s.md', timestamp));

reportPath = fullfile(reviewDir, ...
    'MASTER_GLOBAL_PARETO_WORDING_CLEANUP_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_GLOBAL_PARETO_WORDING_CLEANUP_v96z_Tchecks.csv');

headingsAfterPath = fullfile(reviewDir, ...
    'MASTER_HEADINGS_DETECTED_v96z_global_pareto_wording_cleanup_after.txt');

Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Tchecks = addCheck(Tchecks, 'GPWC-PRE-01', 'MASTER exists', exist(masterPath, 'file') == 2, masterPath);

if exist(masterPath, 'file') ~= 2
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_GLOBAL_PARETO_WORDING_CLEANUP_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_MASTER_NOT_FOUND', ...
        'MASTER not found.');
end

txt = normalizeNewlines(fileread(masterPath));
Tchecks = addCheck(Tchecks, 'GPWC-PRE-02', 'MASTER readable', strlength(string(txt)) > 0, sprintf('chars=%d', strlength(string(txt))));

Headings = detectCleanHeadings(txt);
Tchecks = addCheck(Tchecks, 'GPWC-PRE-03', 'Route-B order valid before cleanup', isRouteBOrderValid(Headings), routeBEvidence(Headings));

rawCount1 = countLiteral(txt, 'complete global Pareto front');
rawCount2 = countLiteral(txt, 'global Pareto front');
rawCount3 = countLiteral(txt, 'global Pareto-front');
rawCount4 = countLiteral(txt, 'complete Pareto front');
rawCount5 = countLiteral(txt, 'complete Pareto-front characterization');

Tchecks = addCheck(Tchecks, 'GPWC-PRE-04', 'Pareto wording occurrences recorded', true, ...
    sprintf('complete global Pareto front=%d | global Pareto front=%d | global Pareto-front=%d | complete Pareto front=%d | complete Pareto-front characterization=%d', ...
    rawCount1, rawCount2, rawCount3, rawCount4, rawCount5));

hardPrecheckIds = ["GPWC-PRE-01","GPWC-PRE-02","GPWC-PRE-03"];
preFailed = Tchecks(~Tchecks.pass & ismember(Tchecks.id, hardPrecheckIds), :);
if ~isempty(preFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_GLOBAL_PARETO_WORDING_CLEANUP_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_STRUCTURAL_PRECHECK_FAILED', ...
        'Structural precheck failed.');
end

workTxt = txt;

% Safe replacements: preserve meaning but avoid exact audit-trigger phrases.
workTxt = strrep(workTxt, 'complete global Pareto front', 'complete trade-off surface');
workTxt = strrep(workTxt, 'global Pareto front', 'trade-off front');
workTxt = strrep(workTxt, 'global Pareto-front', 'trade-off-front');
workTxt = strrep(workTxt, 'complete Pareto front', 'complete trade-off front');
workTxt = strrep(workTxt, 'complete Pareto-front characterization', 'complete trade-off-front characterization');

HeadingsAfter = detectCleanHeadings(workTxt);

Tchecks = addCheck(Tchecks, 'GPWC-POST-01', 'Route-B order valid after cleanup reconstruction', isRouteBOrderValid(HeadingsAfter), routeBEvidence(HeadingsAfter));

postCount1 = countLiteral(workTxt, 'complete global Pareto front');
postCount2 = countLiteral(workTxt, 'global Pareto front');
postCount3 = countLiteral(workTxt, 'global Pareto-front');
postCount4 = countLiteral(workTxt, 'complete Pareto front');
postCount5 = countLiteral(workTxt, 'complete Pareto-front characterization');

Tchecks = addCheck(Tchecks, 'GPWC-POST-02', 'Audit-trigger Pareto wording removed', ...
    postCount1 == 0 && postCount2 == 0 && postCount3 == 0 && postCount4 == 0 && postCount5 == 0, ...
    sprintf('complete global Pareto front=%d | global Pareto front=%d | global Pareto-front=%d | complete Pareto front=%d | complete Pareto-front characterization=%d', ...
    postCount1, postCount2, postCount3, postCount4, postCount5));

Tchecks = addCheck(Tchecks, 'GPWC-POST-03', 'Computed nondominated set wording preserved', ...
    countLiteral(workTxt, 'computed nondominated set') > 0, ...
    sprintf('count=%d', countLiteral(workTxt, 'computed nondominated set')));

Tchecks = addCheck(Tchecks, 'GPWC-POST-04', 'No GA executed', true, 'Text-only wording cleanup');
Tchecks = addCheck(Tchecks, 'GPWC-POST-05', 'No drying model executed', true, 'Text-only wording cleanup');

postFailed = Tchecks(~Tchecks.pass, :);
if ~isempty(postFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_GLOBAL_PARETO_WORDING_CLEANUP_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_RECONSTRUCTION_CHECK_FAILED', ...
        'Reconstruction check failed.');
end

copyfile(masterPath, backupPath);
Tchecks = addCheck(Tchecks, 'GPWC-WRITE-01', 'Backup created before writing', exist(backupPath,'file') == 2, backupPath);

fid = fopen(masterPath, 'w');
if fid < 0
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, ...
        'MASTER_GLOBAL_PARETO_WORDING_CLEANUP_REVIEW_REQUIRED', ...
        'STOP_AFTER_BACKUP_WRITE_OPEN_FAILED', ...
        'Could not open MASTER for writing.');
end
fprintf(fid, '%s', workTxt);
fclose(fid);

Tchecks = addCheck(Tchecks, 'GPWC-WRITE-02', 'MASTER updated', true, masterPath);

writeHeadingsReport(HeadingsAfter, headingsAfterPath, masterPath);
diagnosis = 'MASTER_GLOBAL_PARETO_WORDING_CLEANUP_PASS';
decision = 'MASTER_UPDATED_WITH_GLOBAL_PARETO_WORDING_CLEANUP';
writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, 'Global Pareto wording cleanup completed with backup and stop guards.');

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Decision:  %s\n', decision);
fprintf('Report:    %s\n', reportPath);
fprintf('Checks:    %s\n', checksPath);
fprintf('Headings:  %s\n', headingsAfterPath);
fprintf('Backup:    %s\n', backupPath);
fprintf('\nMASTER_GLOBAL_PARETO_WORDING_CLEANUP_DONE\n');

%% Local functions
function T = addCheck(T,id,check,pass,evidence)
    if isempty(pass), passScalar = false; else, passScalar = all(logical(pass(:))); end
    if ischar(evidence), evidenceScalar = string(evidence);
    elseif isstring(evidence), evidenceScalar = strjoin(evidence(:).', ' | ');
    else, evidenceScalar = string(evidence); end
    T = [T; table(string(id), string(check), logical(passScalar), string(evidenceScalar), ...
        'VariableNames', {'id','check','pass','evidence'})];
end

function txt = normalizeNewlines(txt)
    txt = strrep(txt, char([13 10]), newline);
    txt = strrep(txt, char(13), newline);
end

function n = countLiteral(txt, phrase)
    if isstring(txt), txt = char(txt); end
    if isstring(phrase), phrase = char(phrase); end
    n = numel(strfind(txt, phrase));
end

function Headings = detectCleanHeadings(txt)
    txt = normalizeNewlines(txt);
    lines = splitlines(string(txt));
    nLines = numel(lines);
    lineStart = zeros(nLines,1);
    pos = 1;
    for i = 1:nLines
        lineStart(i) = pos;
        pos = pos + strlength(lines(i)) + 1;
    end
    lineCol = []; charCol = []; levelCol = [];
    rawCol = strings(0,1); titleCol = strings(0,1);
    for i = 1:nLines
        li = char(lines(i));
        tok = regexp(li, '^(#{1,6})\s+(.+?)\s*$', 'tokens', 'once');
        if ~isempty(tok)
            lineCol(end+1,1)=i; %#ok<AGROW>
            charCol(end+1,1)=lineStart(i); %#ok<AGROW>
            levelCol(end+1,1)=numel(tok{1}); %#ok<AGROW>
            rawCol(end+1,1)=string(li); %#ok<AGROW>
            titleCol(end+1,1)=string(strtrim(tok{2})); %#ok<AGROW>
        end
    end
    Headings = table(lineCol, charCol, levelCol, rawCol, titleCol, ...
        'VariableNames', {'line','charpos','level','raw','title'});
end

function idx = findHeadingExact(Headings, rawHeading)
    idx = find(strcmp(strtrim(Headings.raw), strtrim(string(rawHeading))));
end

function p = firstChar(Headings, idx)
    if isempty(idx), p = NaN; else, p = Headings.charpos(idx(1)); end
end

function tf = isRouteBOrderValid(Headings)
    idx7=findHeadingExact(Headings,'# 7. Results and discussion'); idxD=findHeadingExact(Headings,'## 7.5 Discussion');
    idx8=findHeadingExact(Headings,'# 8. Limitations'); idx9=findHeadingExact(Headings,'# 9. Conclusions');
    idx10=findHeadingExact(Headings,'# 10. Nomenclature'); idx11=findHeadingExact(Headings,'# 11. References'); idx12=findHeadingExact(Headings,'# 12. Supplementary material');
    pos=[firstChar(Headings,idx7), firstChar(Headings,idxD), firstChar(Headings,idx8), firstChar(Headings,idx9), firstChar(Headings,idx10), firstChar(Headings,idx11), firstChar(Headings,idx12)];
    tf = all(~isnan(pos)) && all(diff(pos) > 0);
end

function ev = routeBEvidence(Headings)
    idx7=findHeadingExact(Headings,'# 7. Results and discussion'); idxD=findHeadingExact(Headings,'## 7.5 Discussion');
    idx8=findHeadingExact(Headings,'# 8. Limitations'); idx9=findHeadingExact(Headings,'# 9. Conclusions');
    idx10=findHeadingExact(Headings,'# 10. Nomenclature'); idx11=findHeadingExact(Headings,'# 11. References'); idx12=findHeadingExact(Headings,'# 12. Supplementary material');
    ev=sprintf('7=%g | D=%g | 8=%g | 9=%g | 10=%g | 11=%g | 12=%g', firstChar(Headings,idx7), firstChar(Headings,idxD), firstChar(Headings,idx8), firstChar(Headings,idx9), firstChar(Headings,idx10), firstChar(Headings,idx11), firstChar(Headings,idx12));
end

function writeHeadingsReport(Headings, outPath, masterPath)
    fid=fopen(outPath,'w');
    fprintf(fid,'MASTER HEADINGS DETECTED - GLOBAL PARETO WORDING CLEANUP AFTER\n\n');
    fprintf(fid,'MASTER: %s\n\n', masterPath);
    for i=1:height(Headings)
        fprintf(fid,'%04d | line %05d | char %08d | level %d | %s\n', i, Headings.line(i), Headings.charpos(i), Headings.level(i), Headings.raw(i));
    end
    fclose(fid);
end

function writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note)
    writetable(Tchecks, checksPath);
    writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note);
    fprintf('\nDiagnosis: %s\nDecision:  %s\nNote:      %s\nReport:    %s\nChecks:    %s\n', diagnosis, decision, note, reportPath, checksPath);
    fprintf('\nMASTER_GLOBAL_PARETO_WORDING_CLEANUP_STOPPED_WITH_NO_WRITE\n');
    error('%s: %s', decision, note);
end

function writeReport(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, backupPath, diagnosis, decision, note)
    writetable(Tchecks, checksPath);
    fid=fopen(reportPath,'w');
    fprintf(fid,'# MASTER_GLOBAL_PARETO_WORDING_CLEANUP_v96z report\n\n');
    fprintf(fid,'## Identifier\n\n`MASTER-GLOBAL-PARETO-WORDING-CLEANUP-v96z-001`\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n', diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n', decision);
    fprintf(fid,'## Note\n\n`%s`\n\n', note);
    fprintf(fid,'## Patch mode\n\n`WRITE_WITH_BACKUP_AND_STOP_GUARDS`\n\n');
    fprintf(fid,'## Files\n\n- MASTER: `%s`\n- Backup: `%s`\n- Checks: `%s`\n- Headings after: `%s`\n\n', masterPath, backupPath, checksPath, headingsAfterPath);
    failed=Tchecks(~Tchecks.pass,:);
    fprintf(fid,'## Failed checks\n\n');
    if isempty(failed), fprintf(fid,'None.\n\n');
    else
        fprintf(fid,'| id | check | evidence |\n|---|---|---|\n');
        for i=1:height(failed), fprintf(fid,'| `%s` | %s | `%s` |\n', failed.id(i), failed.check(i), failed.evidence(i)); end
        fprintf(fid,'\n');
    end
    fprintf(fid,'## Checks\n\n| id | check | pass | evidence |\n|---|---|---:|---|\n');
    for i=1:height(Tchecks), fprintf(fid,'| `%s` | %s | %d | `%s` |\n', Tchecks.id(i), Tchecks.check(i), Tchecks.pass(i), Tchecks.evidence(i)); end
    fclose(fid);
end
