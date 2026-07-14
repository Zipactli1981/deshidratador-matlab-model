%% export_master_manuscript_preliminary_review_v96z_v2.m
% 9.6z-preview-a
% MASTER-MANUSCRIPT-PRELIMINARY-REVIEW-v96z-001
% EXPORT_REVIEW_COPY
%
% Purpose:
%   Generate a preliminary review copy from MASTER_manuscript_v01.md.
%
% Outputs:
%   - Markdown review copy with review-status banner.
%   - HTML review copy with simple article-like layout for browser review.
%   - Section inventory.
%   - Export report.
%
% Scope:
%   - READ-ONLY with respect to MASTER.
%   - Does not modify MASTER.
%   - Does not run GA.
%   - Does not run the drying model.
%   - Does not attempt final citation verification.

clear; clc;

fprintf('\n=== MASTER MANUSCRIPT PRELIMINARY REVIEW EXPORT v96z ===\n');

rootDir = 'C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA';

masterPath = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'draft_sections', ...
    'MASTER_manuscript_v01.md');

reviewDir = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'review');

previewDir = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'preliminary_review');

if ~exist(reviewDir, 'dir')
    mkdir(reviewDir);
end

if ~exist(previewDir, 'dir')
    mkdir(previewDir);
end

timestamp = datestr(now, 'yyyymmdd_HHMMSS');

mdOutPath = fullfile(previewDir, ...
    sprintf('MASTER_manuscript_v96z_preliminary_review_%s.md', timestamp));

htmlOutPath = fullfile(previewDir, ...
    sprintf('MASTER_manuscript_v96z_preliminary_review_%s.html', timestamp));

inventoryOutPath = fullfile(previewDir, ...
    sprintf('MASTER_manuscript_v96z_preliminary_review_section_inventory_%s.csv', timestamp));

reportPath = fullfile(reviewDir, ...
    'MASTER_MANUSCRIPT_PRELIMINARY_REVIEW_EXPORT_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_MANUSCRIPT_PRELIMINARY_REVIEW_EXPORT_v96z_Tchecks.csv');

Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Tchecks = addCheck(Tchecks, 'MPR-PRE-01', 'MASTER exists', exist(masterPath, 'file') == 2, masterPath);

if exist(masterPath, 'file') ~= 2
    writeReportAndStop(Tchecks, reportPath, checksPath, masterPath, mdOutPath, htmlOutPath, inventoryOutPath, ...
        'MASTER_MANUSCRIPT_PRELIMINARY_REVIEW_EXPORT_REVIEW_REQUIRED', ...
        'STOP_EXPORT_MASTER_NOT_FOUND', ...
        'MASTER not found.');
end

txt = normalizeNewlines(fileread(masterPath));
Tchecks = addCheck(Tchecks, 'MPR-PRE-02', 'MASTER readable', strlength(string(txt)) > 0, sprintf('chars=%d', strlength(string(txt))));

Headings = detectCleanHeadings(txt);
Tchecks = addCheck(Tchecks, 'MPR-PRE-03', 'Route-B order valid before export', isRouteBOrderValid(Headings), routeBEvidence(Headings));

expectedMain = [
    "# 1. Abstract"
    "# 2. Keywords"
    "# 3. Introduction"
    "# 4. System description"
    "# 5. Mathematical model"
    "# 6. Optimization methodology"
    "# 7. Results and discussion"
    "# 8. Limitations"
    "# 9. Conclusions"
    "# 10. Nomenclature"
    "# 11. References"
    "# 12. Supplementary material"
];

missing = strings(0,1);
for k = 1:numel(expectedMain)
    if isempty(findHeadingExact(Headings, expectedMain(k)))
        missing(end+1,1) = expectedMain(k); %#ok<AGROW>
    end
end

Tchecks = addCheck(Tchecks, 'MPR-PRE-04', 'All main manuscript sections detected', isempty(missing), ...
    ifelseStr(isempty(missing), 'all detected', strjoin(missing, ' | ')));

pendingCount = countLiteral(txt, '`STATUS: PENDING`');
requiredReferencesCount = countLiteral(txt, 'Required references:');
globalParetoCount = countLiteral(txt, 'global Pareto front') + countLiteral(txt, 'global Pareto-front') + countLiteral(txt, 'complete global Pareto front');

Tchecks = addCheck(Tchecks, 'MPR-PRE-05', 'No remaining STATUS: PENDING markers', pendingCount == 0, sprintf('pending=%d', pendingCount));
Tchecks = addCheck(Tchecks, 'MPR-PRE-06', 'No Required references scaffold remains', requiredReferencesCount == 0, sprintf('Required references=%d', requiredReferencesCount));
Tchecks = addCheck(Tchecks, 'MPR-PRE-07', 'No audit-trigger global Pareto wording remains', globalParetoCount == 0, sprintf('count=%d', globalParetoCount));

% Informational checks that should not block preliminary review.
citationHits = countCitationLikeMarkers(txt);
computedNondomCount = countLiteral(txt, 'computed nondominated set');

Tchecks = addCheck(Tchecks, 'MPR-INFO-01', 'Citation markers informational for preliminary review', true, sprintf('citation_like_hits=%d', citationHits));
Tchecks = addCheck(Tchecks, 'MPR-INFO-02', 'Computed nondominated set repetition informational for preliminary review', true, sprintf('count=%d', computedNondomCount));
Tchecks = addCheck(Tchecks, 'MPR-INFO-03', 'MASTER is not modified by this export', true, 'READ_ONLY_EXPORT');

hardPrecheckIds = ["MPR-PRE-01","MPR-PRE-02","MPR-PRE-03","MPR-PRE-04","MPR-PRE-05","MPR-PRE-06","MPR-PRE-07"];
preFailed = Tchecks(~Tchecks.pass & ismember(Tchecks.id, hardPrecheckIds), :);
if ~isempty(preFailed)
    writeReportAndStop(Tchecks, reportPath, checksPath, masterPath, mdOutPath, htmlOutPath, inventoryOutPath, ...
        'MASTER_MANUSCRIPT_PRELIMINARY_REVIEW_EXPORT_REVIEW_REQUIRED', ...
        'STOP_EXPORT_PRECHECK_FAILED', ...
        'Preliminary review export precheck failed.');
end

banner = sprintf(['<!--\n' ...
'PRELIMINARY REVIEW COPY\n' ...
'Generated: %s\n' ...
'Source MASTER: %s\n' ...
'Scope: internal reading review, not pre-submission.\n' ...
'Known open items: final source-verified references, in-text citations, style cleanup for repeated terms, final journal formatting.\n' ...
'-->\n\n' ...
'# Preliminary review copy — MASTER manuscript v96z\n\n' ...
'> This copy is intended for full-content reading review. It is not a pre-submission version. The reference section remains a verification scaffold; in-text citations have not yet been finalized.\n\n' ...
'---\n\n'], datestr(now, 'yyyy-mm-dd HH:MM:SS'), masterPath);

mdReview = char(string(char(banner)) + string(char(txt)));

fid = fopen(mdOutPath, 'w');
if fid < 0
    writeReportAndStop(Tchecks, reportPath, checksPath, masterPath, mdOutPath, htmlOutPath, inventoryOutPath, ...
        'MASTER_MANUSCRIPT_PRELIMINARY_REVIEW_EXPORT_REVIEW_REQUIRED', ...
        'STOP_EXPORT_MD_WRITE_FAILED', ...
        'Could not write markdown review copy.');
end
fprintf(fid, '%s', mdReview);
fclose(fid);

Tchecks = addCheck(Tchecks, 'MPR-WRITE-01', 'Markdown preliminary review copy written', exist(mdOutPath, 'file') == 2, mdOutPath);

htmlReview = buildHtmlReview(mdReview, masterPath, timestamp);

fid = fopen(htmlOutPath, 'w');
if fid < 0
    writeReportAndStop(Tchecks, reportPath, checksPath, masterPath, mdOutPath, htmlOutPath, inventoryOutPath, ...
        'MASTER_MANUSCRIPT_PRELIMINARY_REVIEW_EXPORT_REVIEW_REQUIRED', ...
        'STOP_EXPORT_HTML_WRITE_FAILED', ...
        'Could not write HTML review copy.');
end
fprintf(fid, '%s', htmlReview);
fclose(fid);

Tchecks = addCheck(Tchecks, 'MPR-WRITE-02', 'HTML preliminary review copy written', exist(htmlOutPath, 'file') == 2, htmlOutPath);

Inventory = buildSectionInventory(txt, Headings);
writetable(Inventory, inventoryOutPath);
Tchecks = addCheck(Tchecks, 'MPR-WRITE-03', 'Section inventory written', exist(inventoryOutPath, 'file') == 2, inventoryOutPath);

Tchecks = addCheck(Tchecks, 'MPR-POST-01', 'No GA executed', true, 'Export only');
Tchecks = addCheck(Tchecks, 'MPR-POST-02', 'No drying model executed', true, 'Export only');

failedFinal = Tchecks(~Tchecks.pass, :);
if ~isempty(failedFinal)
    writeReportAndStop(Tchecks, reportPath, checksPath, masterPath, mdOutPath, htmlOutPath, inventoryOutPath, ...
        'MASTER_MANUSCRIPT_PRELIMINARY_REVIEW_EXPORT_REVIEW_REQUIRED', ...
        'STOP_EXPORT_POSTCHECK_FAILED', ...
        'Postcheck failed.');
end

diagnosis = 'MASTER_MANUSCRIPT_PRELIMINARY_REVIEW_EXPORT_PASS';
decision = 'PRELIMINARY_REVIEW_COPY_EXPORTED';
writeReport(Tchecks, reportPath, checksPath, masterPath, mdOutPath, htmlOutPath, inventoryOutPath, diagnosis, decision, 'Preliminary review copy exported.');

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Decision:  %s\n', decision);
fprintf('Markdown:  %s\n', mdOutPath);
fprintf('HTML:      %s\n', htmlOutPath);
fprintf('Inventory: %s\n', inventoryOutPath);
fprintf('Report:    %s\n', reportPath);
fprintf('Checks:    %s\n', checksPath);
fprintf('\nMASTER_MANUSCRIPT_PRELIMINARY_REVIEW_EXPORT_DONE\n');

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

function s = ifelseStr(cond, a, b)
    if cond, s = a; else, s = b; end
end

function n = countLiteral(txt, phrase)
    if isstring(txt), txt = char(txt); end
    if isstring(phrase), phrase = char(phrase); end
    n = numel(strfind(txt, phrase));
end

function n = countCitationLikeMarkers(txt)
    s = string(txt);
    patterns = ["\[[0-9]+\]", "\([A-Z][A-Za-z\-]+,\s*[0-9]{4}\)", "\[[A-Z]+-[A-Z0-9\-]+\]"];
    n = 0;
    for k = 1:numel(patterns)
        m = regexp(char(s), char(patterns(k)), 'match');
        n = n + numel(m);
    end
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

function Inventory = buildSectionInventory(txt, Headings)
    n = height(Headings);
    wordCounts = zeros(n,1);
    charCounts = zeros(n,1);
    statuses = strings(n,1);
    for i = 1:n
        startPos = Headings.charpos(i);
        endPos = strlength(string(txt)) + 1;
        for j = i+1:n
            if Headings.level(j) <= Headings.level(i)
                endPos = Headings.charpos(j);
                break;
            end
        end
        seg = char(extractBetween(string(txt), startPos, endPos-1));
        charCounts(i) = strlength(string(seg));
        words = regexp(seg, '\S+', 'match');
        wordCounts(i) = numel(words);
        st = regexp(seg, '`STATUS:\s*([^`]+)`', 'tokens', 'once');
        if isempty(st), statuses(i) = ""; else, statuses(i) = string(strtrim(st{1})); end
    end
    Inventory = table(Headings.line, Headings.charpos, Headings.level, Headings.raw, statuses, wordCounts, charCounts, ...
        'VariableNames', {'line','charpos','level','heading','status','word_count','char_count'});
end

function html = buildHtmlReview(md, masterPath, timestamp)
    % v2: force scalar char/string before splitlines. This avoids MATLAB
    % splitlines errors caused by non-scalar string arrays with unequal
    % delimiter counts.
    if isstring(md)
        mdScalar = strjoin(md(:), newline);
    else
        mdScalar = string(char(md));
    end
    mdScalar = normalizeNewlines(char(mdScalar));
    lines = splitlines(string(mdScalar));
    body = strings(0,1);
    inCode = false;
    for i = 1:numel(lines)
        line = char(lines(i));
        if startsWith(strtrim(line), '```')
            if ~inCode
                body(end+1,1) = "<pre><code>"; %#ok<AGROW>
                inCode = true;
            else
                body(end+1,1) = "</code></pre>"; %#ok<AGROW>
                inCode = false;
            end
            continue;
        end
        if inCode
            body(end+1,1) = string(escapeHtml(line)); %#ok<AGROW>
            continue;
        end
        if startsWith(line, '<!--') || startsWith(line, '-->')
            continue;
        end
        if startsWith(strtrim(line), '---')
            body(end+1,1) = "<hr>"; %#ok<AGROW>
            continue;
        end
        tok = regexp(line, '^(#{1,6})\s+(.+)$', 'tokens', 'once');
        if ~isempty(tok)
            lvl = numel(tok{1});
            content = inlineMarkdown(escapeHtml(tok{2}));
            body(end+1,1) = sprintf('<h%d>%s</h%d>', lvl, content, lvl); %#ok<AGROW>
            continue;
        end
        if startsWith(strtrim(line), '> ')
            content = extractAfter(string(strtrim(line)), 2);
            body(end+1,1) = "<blockquote>" + inlineMarkdown(escapeHtml(char(content))) + "</blockquote>"; %#ok<AGROW>
            continue;
        end
        if startsWith(strtrim(line), '- ')
            content = extractAfter(string(strtrim(line)), 2);
            body(end+1,1) = "<p class=""list-item"">• " + inlineMarkdown(escapeHtml(char(content))) + "</p>"; %#ok<AGROW>
            continue;
        end
        if strlength(string(strtrim(line))) == 0
            body(end+1,1) = ""; %#ok<AGROW>
        else
            body(end+1,1) = "<p>" + inlineMarkdown(escapeHtml(line)) + "</p>"; %#ok<AGROW>
        end
    end

    css = [
"<style>" newline ...
"body{font-family: Georgia, 'Times New Roman', serif; margin:0; background:#f4f4f1; color:#1f2933;}" newline ...
".page{max-width:920px; margin:36px auto; background:#fff; padding:56px 68px; box-shadow:0 3px 22px rgba(0,0,0,.12);}" newline ...
".meta{font-family:Arial, sans-serif; font-size:12px; color:#5b6670; border:1px solid #d7dce0; background:#f8fafb; padding:12px 14px; margin-bottom:28px;}" newline ...
"h1{font-family:Arial, sans-serif; font-size:28px; border-bottom:2px solid #1f2933; padding-bottom:8px; margin-top:34px;}" newline ...
"h2{font-family:Arial, sans-serif; font-size:21px; margin-top:30px; border-bottom:1px solid #d7dce0; padding-bottom:4px;}" newline ...
"h3{font-family:Arial, sans-serif; font-size:17px; margin-top:24px;}" newline ...
"h4,h5,h6{font-family:Arial, sans-serif;}" newline ...
"p{font-size:16px; line-height:1.55; margin:10px 0;}" newline ...
"blockquote{font-family:Arial, sans-serif; border-left:4px solid #9aa6b2; margin:18px 0; padding:10px 14px; background:#f8fafb; color:#3b4752;}" newline ...
"code{font-family:Consolas, 'Courier New', monospace; background:#eef2f5; padding:1px 4px; border-radius:3px;}" newline ...
"pre{background:#101820; color:#f7f7f7; padding:14px; overflow:auto; border-radius:4px;}" newline ...
".list-item{margin-left:20px;}" newline ...
".status{font-family:Arial, sans-serif; color:#7b341e; background:#fff7ed; border:1px solid #fed7aa; padding:8px 10px; display:inline-block;}" newline ...
"hr{border:0; border-top:1px solid #d7dce0; margin:28px 0;}" newline ...
"@media print{body{background:#fff}.page{box-shadow:none; margin:0; padding:36px 48px; max-width:none}}" newline ...
"</style>" newline ...
];

    meta = sprintf(['<div class="meta"><strong>Preliminary review copy</strong><br>' ...
        'Generated: %s<br>Source MASTER: %s<br>' ...
        'Scope: internal reading review; not pre-submission. Open items: final references, in-text citations, style cleanup, journal formatting.</div>'], ...
        datestr(now, 'yyyy-mm-dd HH:MM:SS'), escapeHtml(masterPath));

    bodyScalar = strjoin(body(:), newline);
    html = char(string('<!doctype html><html><head><meta charset="utf-8"><title>MASTER manuscript v96z preliminary review</title>') + ...
        string(char(css)) + string('</head><body><main class="page">') + string(char(meta)) + string(newline) + ...
        string(bodyScalar) + string('</main></body></html>'));
end

function out = escapeHtml(in)
    out = strrep(in, '&', '&amp;');
    out = strrep(out, '<', '&lt;');
    out = strrep(out, '>', '&gt;');
end

function out = inlineMarkdown(in)
    out = regexprep(in, '`([^`]+)`', '<code>$1</code>');
    out = regexprep(out, '\*\*([^*]+)\*\*', '<strong>$1</strong>');
    out = regexprep(out, '\*([^*]+)\*', '<em>$1</em>');
    out = regexprep(out, '^`STATUS:\s*([^`]+)`$', '<span class="status">STATUS: $1</span>');
end

function writeReportAndStop(Tchecks, reportPath, checksPath, masterPath, mdOutPath, htmlOutPath, inventoryOutPath, diagnosis, decision, note)
    writetable(Tchecks, checksPath);
    writeReport(Tchecks, reportPath, checksPath, masterPath, mdOutPath, htmlOutPath, inventoryOutPath, diagnosis, decision, note);
    fprintf('\nDiagnosis: %s\nDecision:  %s\nNote:      %s\nReport:    %s\nChecks:    %s\n', diagnosis, decision, note, reportPath, checksPath);
    fprintf('\nMASTER_MANUSCRIPT_PRELIMINARY_REVIEW_EXPORT_STOPPED\n');
    error('%s: %s', decision, note);
end

function writeReport(Tchecks, reportPath, checksPath, masterPath, mdOutPath, htmlOutPath, inventoryOutPath, diagnosis, decision, note)
    writetable(Tchecks, checksPath);
    fid=fopen(reportPath,'w');
    fprintf(fid,'# MASTER_MANUSCRIPT_PRELIMINARY_REVIEW_EXPORT_v96z report\n\n');
    fprintf(fid,'## Identifier\n\n`MASTER-MANUSCRIPT-PRELIMINARY-REVIEW-v96z-001`\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n', diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n', decision);
    fprintf(fid,'## Note\n\n`%s`\n\n', note);
    fprintf(fid,'## Export mode\n\n`READ_ONLY_EXPORT`\n\n');
    fprintf(fid,'## Files\n\n- MASTER: `%s`\n- Markdown: `%s`\n- HTML: `%s`\n- Inventory: `%s`\n- Checks: `%s`\n\n', masterPath, mdOutPath, htmlOutPath, inventoryOutPath, checksPath);
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
