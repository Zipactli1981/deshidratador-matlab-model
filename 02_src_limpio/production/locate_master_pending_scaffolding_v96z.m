%% locate_master_pending_scaffolding_v96z.m
% 9.6z-audit-d1
% MASTER-PENDING-SCAFFOLDING-LOCATOR-v96z-001
% READ_ONLY
%
% Purpose:
%   Locate pending/scaffolding markers and known editorial issues in
%   MASTER_manuscript_v01.md.
%
% This script:
%   - Reads MASTER only.
%   - Does not modify MASTER.
%   - Does not run GA.
%   - Does not run the drying model.
%   - Writes locator reports only.

clear; clc;

fprintf('\n=== MASTER PENDING SCAFFOLDING LOCATOR v96z ===\n');

rootDir = 'C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA';

masterPath = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'draft_sections', ...
    'MASTER_manuscript_v01.md');

reviewDir = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'review');

if ~exist(reviewDir, 'dir')
    mkdir(reviewDir);
end

reportPath = fullfile(reviewDir, ...
    'MASTER_PENDING_SCAFFOLDING_LOCATOR_v96z_report.md');

findingsPath = fullfile(reviewDir, ...
    'MASTER_PENDING_SCAFFOLDING_LOCATOR_v96z_findings.csv');

checksPath = fullfile(reviewDir, ...
    'MASTER_PENDING_SCAFFOLDING_LOCATOR_v96z_Tchecks.csv');

Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Findings = table(string.empty, string.empty, string.empty, string.empty, ...
    string.empty, string.empty, string.empty, ...
    'VariableNames', {'id','category','severity','line','section','matchedText','recommendation'});

Tchecks = addCheck(Tchecks, 'MPSL-001', 'MASTER exists', ...
    exist(masterPath, 'file') == 2, masterPath);

if exist(masterPath, 'file') ~= 2
    writetable(Tchecks, checksPath);
    error('MASTER not found: %s', masterPath);
end

txt = fileread(masterPath);
txt = normalizeNewlines(txt);
lines = splitlines(string(txt));

Tchecks = addCheck(Tchecks, 'MPSL-002', 'MASTER readable', ...
    strlength(string(txt)) > 0, sprintf('chars=%d lines=%d', strlength(string(txt)), numel(lines)));

Headings = detectCleanHeadings(txt);
Tchecks = addCheck(Tchecks, 'MPSL-003', 'Clean headings detected', ...
    height(Headings) > 0, sprintf('clean_headings=%d', height(Headings)));

%% Search targets

targets = table( ...
    ["STATUS_PENDING"; ...
     "EXPECTED_CONTENT"; ...
     "EXPECTED_FIGURE"; ...
     "CANDIDATE_KEYWORDS"; ...
     "REQUIRED_REFERENCES"; ...
     "AWKWARD_HYBRID_BASELINE"; ...
     "COMPUTED_NONDOMINATED_SET"; ...
     "TABLE_TOKEN"; ...
     "FIGURE_TOKEN"; ...
     "CITATION_PLACEHOLDER"], ...
    ["`STATUS: PENDING`"; ...
     "Expected content:"; ...
     "Expected figure:"; ...
     "Candidate keywords:"; ...
     "Required references:"; ...
     "R1_solution_3 showed a 43.07% reduction, while For R1_solution_9"; ...
     "computed nondominated set"; ...
     "TABLE_"; ...
     "FIG_"; ...
     "CITATION_NEEDED"], ...
    ["Completeness"; ...
     "Scaffolding"; ...
     "Scaffolding"; ...
     "Front matter"; ...
     "References"; ...
     "Style/grammar"; ...
     "Redundancy"; ...
     "Tables"; ...
     "Figures"; ...
     "References"], ...
    ["MAJOR"; ...
     "MAJOR"; ...
     "MAJOR"; ...
     "MINOR"; ...
     "MAJOR"; ...
     "MINOR"; ...
     "MINOR"; ...
     "MINOR"; ...
     "MAJOR"; ...
     "MAJOR"], ...
    'VariableNames', {'id','needle','category','severity'} ...
);

%% Locate target matches line by line

for t = 1:height(targets)
    needle = targets.needle(t);
    count = 0;

    for i = 1:numel(lines)
        if contains(lines(i), needle)
            count = count + 1;
            section = currentSectionForLine(Headings, i);
            snippet = char(strtrim(lines(i)));
            if strlength(string(snippet)) > 220
                snippet = char(extractBefore(string(snippet), 221) + "...");
            end

            rec = recommendationForTarget(targets.id(t));
            Findings = addFinding(Findings, sprintf('MPSL-F%03d', height(Findings)+1), ...
                targets.category(t), targets.severity(t), sprintf('%d', i), ...
                section, snippet, rec);
        end
    end

    Tchecks = addCheck(Tchecks, sprintf('MPSL-%03d', 3+t), ...
        sprintf('Located target: %s', targets.id(t)), ...
        count == 0, sprintf('count=%d', count));
end

%% Additional regexp locators

% Potential unfilled citation placeholders or bracketed TBD-like material.
regexpTargets = {
    'TODO_TBD_MARKERS', '(TODO|TBD|PENDING SOURCE|SOURCE NEEDED|CITE|citation needed)', 'Completeness', 'MAJOR';
    'EMPTY_SECTION_STATUS_LINES', '`STATUS:\s*(PENDING|PARTIAL)`', 'Completeness', 'MAJOR';
    'EXPECTED_STRUCTURE_MARKERS', 'Expected (content|figure|table|structure):', 'Scaffolding', 'MAJOR';
};

for r = 1:size(regexpTargets,1)
    rid = regexpTargets{r,1};
    pat = regexpTargets{r,2};
    cat = regexpTargets{r,3};
    sev = regexpTargets{r,4};
    count = 0;

    for i = 1:numel(lines)
        li = char(lines(i));
        if ~isempty(regexp(li, pat, 'once', 'ignorecase'))
            count = count + 1;
            section = currentSectionForLine(Headings, i);
            snippet = char(strtrim(lines(i)));
            if strlength(string(snippet)) > 220
                snippet = char(extractBefore(string(snippet), 221) + "...");
            end
            Findings = addFinding(Findings, sprintf('MPSL-F%03d', height(Findings)+1), ...
                string(cat), string(sev), sprintf('%d', i), ...
                section, snippet, "Resolve or remove this placeholder before pre-submission.");
        end
    end

    Tchecks = addCheck(Tchecks, sprintf('MPSL-R%03d', r), ...
        sprintf('Regexp locator clear: %s', rid), ...
        count == 0, sprintf('count=%d', count));
end

%% Summaries by category/severity

nMajor = sum(strcmpi(Findings.severity, "MAJOR"));
nMinor = sum(strcmpi(Findings.severity, "MINOR"));
nCritical = sum(strcmpi(Findings.severity, "CRITICAL"));

Tchecks = addCheck(Tchecks, 'MPSL-020', 'No critical locator findings', ...
    nCritical == 0, sprintf('critical=%d', nCritical));

Tchecks = addCheck(Tchecks, 'MPSL-021', 'No major locator findings', ...
    nMajor == 0, sprintf('major=%d', nMajor));

Tchecks = addCheck(Tchecks, 'MPSL-022', 'No minor locator findings', ...
    nMinor == 0, sprintf('minor=%d', nMinor));

%% Diagnosis

if nCritical > 0
    diagnosis = 'MASTER_PENDING_SCAFFOLDING_LOCATOR_CRITICAL_REVIEW_REQUIRED';
    decision = 'INSPECT_CRITICAL_LOCATIONS';
elseif nMajor > 0
    diagnosis = 'MASTER_PENDING_SCAFFOLDING_LOCATOR_REVIEW_REQUIRED';
    decision = 'PATCH_OR_DRAFT_CONTENT_COMPLETION_REQUIRED';
elseif nMinor > 0
    diagnosis = 'MASTER_PENDING_SCAFFOLDING_LOCATOR_MINOR_REVIEW_REQUIRED';
    decision = 'MINOR_EDITORIAL_PATCH_RECOMMENDED';
else
    diagnosis = 'MASTER_PENDING_SCAFFOLDING_LOCATOR_PASS';
    decision = 'NO_PENDING_SCAFFOLDING_TARGETS_DETECTED';
end

%% Write outputs

writetable(Tchecks, checksPath);
writetable(Findings, findingsPath);

fid = fopen(reportPath, 'w');

fprintf(fid, '# MASTER_PENDING_SCAFFOLDING_LOCATOR_v96z report\n\n');
fprintf(fid, '## Identifier\n\n');
fprintf(fid, '`MASTER-PENDING-SCAFFOLDING-LOCATOR-v96z-001`\n\n');
fprintf(fid, '## Mode\n\n');
fprintf(fid, '`READ_ONLY`\n\n');
fprintf(fid, '## Diagnosis\n\n');
fprintf(fid, '`%s`\n\n', diagnosis);
fprintf(fid, '## Decision\n\n');
fprintf(fid, '`%s`\n\n', decision);

fprintf(fid, '## Files\n\n');
fprintf(fid, '- MASTER: `%s`\n', masterPath);
fprintf(fid, '- Findings CSV: `%s`\n', findingsPath);
fprintf(fid, '- Checks CSV: `%s`\n\n', checksPath);

fprintf(fid, '## Summary\n\n');
fprintf(fid, '- Total findings: `%d`\n', height(Findings));
fprintf(fid, '- Critical findings: `%d`\n', nCritical);
fprintf(fid, '- Major findings: `%d`\n', nMajor);
fprintf(fid, '- Minor findings: `%d`\n\n', nMinor);

fprintf(fid, '## Findings by location\n\n');

if isempty(Findings)
    fprintf(fid, 'None.\n\n');
else
    fprintf(fid, '| id | severity | category | line | section | matched text | recommendation |\n');
    fprintf(fid, '|---|---|---|---:|---|---|---|\n');

    for i = 1:height(Findings)
        fprintf(fid, '| `%s` | `%s` | %s | %s | %s | `%s` | %s |\n', ...
            Findings.id(i), Findings.severity(i), Findings.category(i), ...
            Findings.line(i), Findings.section(i), escapePipes(Findings.matchedText(i)), ...
            Findings.recommendation(i));
    end
    fprintf(fid, '\n');
end

fprintf(fid, '## Checks\n\n');
fprintf(fid, '| id | check | pass | evidence |\n');
fprintf(fid, '|---|---|---:|---|\n');

for i = 1:height(Tchecks)
    fprintf(fid, '| `%s` | %s | %d | `%s` |\n', ...
        Tchecks.id(i), Tchecks.check(i), Tchecks.pass(i), Tchecks.evidence(i));
end

fclose(fid);

%% Console output

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Decision:  %s\n', decision);
fprintf('Report:    %s\n', reportPath);
fprintf('Findings:  %s\n', findingsPath);
fprintf('Checks:    %s\n', checksPath);

if ~isempty(Findings)
    fprintf('\nFindings summary:\n');
    disp(Findings(:, {'id','severity','category','line','section','matchedText'}));
end

fprintf('\nMASTER_PENDING_SCAFFOLDING_LOCATOR_DONE\n');

%% Local functions

function T = addCheck(T,id,check,pass,evidence)
    T = [T; table(string(id), string(check), logical(pass), string(evidence), ...
        'VariableNames', {'id','check','pass','evidence'})];
end

function F = addFinding(F,id,category,severity,line,section,matchedText,recommendation)
    F = [F; table(string(id), string(category), string(severity), string(line), ...
        string(section), string(matchedText), string(recommendation), ...
        'VariableNames', {'id','category','severity','line','section','matchedText','recommendation'})];
end

function txt = normalizeNewlines(txt)
    txt = strrep(txt, char([13 10]), newline);
    txt = strrep(txt, char(13), newline);
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

    lineCol = [];
    charCol = [];
    levelCol = [];
    rawCol = strings(0,1);
    titleCol = strings(0,1);

    for i = 1:nLines
        li = char(lines(i));
        tok = regexp(li, '^(#{1,6})\s+(.+?)\s*$', 'tokens', 'once');
        if ~isempty(tok)
            lineCol(end+1,1) = i; %#ok<AGROW>
            charCol(end+1,1) = lineStart(i); %#ok<AGROW>
            levelCol(end+1,1) = numel(tok{1}); %#ok<AGROW>
            rawCol(end+1,1) = string(li); %#ok<AGROW>
            titleCol(end+1,1) = string(strtrim(tok{2})); %#ok<AGROW>
        end
    end

    Headings = table(lineCol, charCol, levelCol, rawCol, titleCol, ...
        'VariableNames', {'line','charpos','level','raw','title'});
end

function section = currentSectionForLine(Headings, lineNo)
    idx = find(Headings.line <= lineNo, 1, 'last');
    if isempty(idx)
        section = "BEFORE_FIRST_HEADING";
    else
        % Prefer nearest top-level section when available, but keep nearest heading context too.
        idxTop = find(Headings.line <= lineNo & Headings.level == 1, 1, 'last');
        if isempty(idxTop)
            section = Headings.raw(idx);
        else
            if idx == idxTop
                section = Headings.raw(idxTop);
            else
                section = Headings.raw(idxTop) + " / " + Headings.raw(idx);
            end
        end
    end
end

function rec = recommendationForTarget(id)
    switch char(id)
        case 'STATUS_PENDING'
            rec = "Replace pending marker with final status or drafted prose.";
        case 'EXPECTED_CONTENT'
            rec = "Convert expected-content scaffold into manuscript prose or remove it after drafting.";
        case 'EXPECTED_FIGURE'
            rec = "Replace expected-figure scaffold with figure callout/caption or remove if not used.";
        case 'CANDIDATE_KEYWORDS'
            rec = "Convert candidate keyword list into finalized keyword section.";
        case 'REQUIRED_REFERENCES'
            rec = "Replace required-reference scaffold with actual references.";
        case 'AWKWARD_HYBRID_BASELINE'
            rec = "Rewrite the local sentence to remove duplicated transition.";
        case 'COMPUTED_NONDOMINATED_SET'
            rec = "Check whether repetition is justified; consolidate wording if it reads redundant.";
        case 'TABLE_TOKEN'
            rec = "Confirm whether table is embedded, cited, or still only referenced by filename.";
        case 'FIGURE_TOKEN'
            rec = "Replace figure placeholder with actual figure callout/caption plan.";
        case 'CITATION_PLACEHOLDER'
            rec = "Replace citation placeholder with final source.";
        otherwise
            rec = "Inspect and resolve before pre-submission.";
    end
end

function out = escapePipes(s)
    out = replace(string(s), "|", "\|");
end
