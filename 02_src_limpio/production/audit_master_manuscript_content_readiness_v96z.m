%% audit_master_manuscript_content_readiness_v96z.m
% 9.6z-audit-d
% MASTER-MANUSCRIPT-CONTENT-READINESS-AUDIT-v96z-001
% READ_ONLY
%
% Purpose:
%   Audit content readiness of MASTER_manuscript_v01.md after Route-B
%   structural validation.
%
% This script:
%   - Reads MASTER only.
%   - Does not modify MASTER.
%   - Does not run GA.
%   - Does not run the drying model.
%   - Writes review reports only.
%
% Scope:
%   - Pending sections.
%   - Duplications/redundancies.
%   - Missing table/figure integration signals.
%   - Missing references/citations.
%   - Provisional cost/CO2 status.
%   - Pre-submission blockers.
%   - Route-B structure sanity.

clear; clc;

fprintf('\n=== MASTER MANUSCRIPT CONTENT READINESS AUDIT v96z ===\n');

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
    'MASTER_MANUSCRIPT_CONTENT_READINESS_AUDIT_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_MANUSCRIPT_CONTENT_READINESS_AUDIT_v96z_Tchecks.csv');

findingsPath = fullfile(reviewDir, ...
    'MASTER_MANUSCRIPT_CONTENT_READINESS_AUDIT_v96z_findings.csv');

sectionInventoryPath = fullfile(reviewDir, ...
    'MASTER_MANUSCRIPT_CONTENT_READINESS_AUDIT_v96z_section_inventory.csv');

Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Findings = table(string.empty, string.empty, string.empty, string.empty, string.empty, ...
    'VariableNames', {'id','severity','category','finding','recommendation'});

Tchecks = addCheck(Tchecks, 'MCRA-001', 'MASTER exists', ...
    exist(masterPath, 'file') == 2, masterPath);

if exist(masterPath, 'file') ~= 2
    writetable(Tchecks, checksPath);
    error('MASTER not found: %s', masterPath);
end

txt = fileread(masterPath);
txt = normalizeNewlines(txt);
txtStr = string(txt);
txtLower = lower(txtStr);

Tchecks = addCheck(Tchecks, 'MCRA-002', 'MASTER readable', ...
    strlength(txtStr) > 0, sprintf('chars=%d', strlength(txtStr)));

Headings = detectCleanHeadings(txt);

Tchecks = addCheck(Tchecks, 'MCRA-003', 'Clean headings detected', ...
    height(Headings) > 0, sprintf('clean_headings=%d', height(Headings)));

SectionInventory = buildSectionInventory(txt, Headings);
writetable(SectionInventory, sectionInventoryPath);

%% Route-B structure sanity

idx7  = findHeadingExact(Headings, '# 7. Results and discussion');
idxD  = findHeadingExact(Headings, '## 7.5 Discussion');
idx8  = findHeadingExact(Headings, '# 8. Limitations');
idx9  = findHeadingExact(Headings, '# 9. Conclusions');
idx10 = findHeadingExact(Headings, '# 10. Nomenclature');
idx11 = findHeadingExact(Headings, '# 11. References');
idx12 = findHeadingExact(Headings, '# 12. Supplementary material');

pos7  = firstChar(Headings, idx7);
posD  = firstChar(Headings, idxD);
pos8  = firstChar(Headings, idx8);
pos9  = firstChar(Headings, idx9);
pos10 = firstChar(Headings, idx10);
pos11 = firstChar(Headings, idx11);
pos12 = firstChar(Headings, idx12);

routeBOK = all(~isnan([pos7 posD pos8 pos9 pos10 pos11 pos12])) && ...
    pos7 < posD && posD < pos8 && pos8 < pos9 && pos9 < pos10 && pos10 < pos11 && pos11 < pos12;

Tchecks = addCheck(Tchecks, 'MCRA-004', 'Route-B order still valid', ...
    routeBOK, sprintf('7=%g | D=%g | 8=%g | 9=%g | 10=%g | 11=%g | 12=%g', pos7,posD,pos8,pos9,pos10,pos11,pos12));

if ~routeBOK
    Findings = addFinding(Findings, 'MCRA-F001', 'CRITICAL', 'Structure', ...
        'Route-B manuscript order is not valid.', ...
        'Do not continue content editing until section order is repaired.');
end

%% Pending sections

pendingPattern = '`STATUS:\s*PENDING`';
pendingMatches = regexp(txt, pendingPattern, 'match');
nPending = numel(pendingMatches);

Tchecks = addCheck(Tchecks, 'MCRA-005', 'No STATUS: PENDING markers remain', ...
    nPending == 0, sprintf('pending_markers=%d', nPending));

if nPending > 0
    Findings = addFinding(Findings, 'MCRA-F002', 'MAJOR', 'Completeness', ...
        sprintf('MASTER still contains %d STATUS: PENDING marker(s).', nPending), ...
        'Draft or integrate pending front matter and methods/system sections before pre-submission.');
end

topPending = detectPendingTopSections(txt, Headings);
if ~isempty(topPending)
    Findings = addFinding(Findings, 'MCRA-F003', 'MAJOR', 'Completeness', ...
        sprintf('Pending top-level sections detected: %s', strjoin(cellstr(topPending), '; ')), ...
        'Prioritize these sections before full editorial polishing.');
end

%% Main section readiness checks

majorSections = [
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
];

for k = 1:numel(majorSections)
    heading = char(majorSections(k));
    idx = findHeadingExact(Headings, heading);
    existsOnce = numel(idx) == 1;
    Tchecks = addCheck(Tchecks, sprintf('MCRA-%03d', 5+k), ...
        sprintf('%s exists once', heading), existsOnce, headingSummary(Headings, idx));

    if ~existsOnce
        Findings = addFinding(Findings, sprintf('MCRA-F%03d', 10+k), 'MAJOR', 'Structure', ...
            sprintf('Section heading not found exactly once: %s.', heading), ...
            'Repair heading inventory before editorial readiness.');
    end
end

%% Sections that are still skeletal by expected-content markers

expectedContentCount = countLiteral(txt, 'Expected content:');
expectedFigureCount  = countLiteral(txt, 'Expected figure:');
candidateKeywordsCount = countLiteral(txt, 'Candidate keywords:');
requiredReferencesCount = countLiteral(txt, 'Required references:');

Tchecks = addCheck(Tchecks, 'MCRA-017', 'No Expected content scaffolding remains', ...
    expectedContentCount == 0, sprintf('Expected content count=%d', expectedContentCount));

Tchecks = addCheck(Tchecks, 'MCRA-018', 'No Expected figure scaffolding remains', ...
    expectedFigureCount == 0, sprintf('Expected figure count=%d', expectedFigureCount));

Tchecks = addCheck(Tchecks, 'MCRA-019', 'No Candidate keywords scaffolding remains', ...
    candidateKeywordsCount == 0, sprintf('Candidate keywords count=%d', candidateKeywordsCount));

Tchecks = addCheck(Tchecks, 'MCRA-020', 'No Required references scaffolding remains', ...
    requiredReferencesCount == 0, sprintf('Required references count=%d', requiredReferencesCount));

if expectedContentCount > 0 || expectedFigureCount > 0 || candidateKeywordsCount > 0 || requiredReferencesCount > 0
    Findings = addFinding(Findings, 'MCRA-F020', 'MAJOR', 'Scaffolding', ...
        'The MASTER still contains skeleton/scaffolding language.', ...
        'Convert scaffolding into manuscript prose before pre-submission readiness.');
end

%% Abstract / Keywords / References content checks

segAbstract = sectionSegmentByHeading(txt, Headings, '# 1. Abstract');
segKeywords = sectionSegmentByHeading(txt, Headings, '# 2. Keywords');
segRefs     = sectionSegmentByHeading(txt, Headings, '# 11. References');

abstractReady = ~contains(string(segAbstract), '`STATUS: PENDING`') && ...
    strlength(strtrim(string(stripHeadingLine(segAbstract)))) > 400;

keywordsReady = ~contains(string(segKeywords), '`STATUS: PENDING`') && ...
    countListItems(segKeywords) >= 4;

referencesReady = ~contains(string(segRefs), '`STATUS: PENDING`') && ...
    countListItems(segRefs) >= 5 && ...
    ~contains(string(segRefs), 'Required references:');

Tchecks = addCheck(Tchecks, 'MCRA-021', 'Abstract appears drafted', ...
    abstractReady, sprintf('abstract_body_chars=%d', strlength(strtrim(string(stripHeadingLine(segAbstract))))));

Tchecks = addCheck(Tchecks, 'MCRA-022', 'Keywords appear finalized', ...
    keywordsReady, sprintf('keyword_list_items=%d', countListItems(segKeywords)));

Tchecks = addCheck(Tchecks, 'MCRA-023', 'References appear populated', ...
    referencesReady, sprintf('reference_list_items=%d', countListItems(segRefs)));

if ~abstractReady
    Findings = addFinding(Findings, 'MCRA-F021', 'MAJOR', 'Front matter', ...
        'Abstract is not yet drafted as manuscript prose.', ...
        'Draft abstract after Results, Discussion, Limitations, and Conclusions are stable.');
end

if ~keywordsReady
    Findings = addFinding(Findings, 'MCRA-F022', 'MINOR', 'Front matter', ...
        'Keywords remain candidate-like or incomplete.', ...
        'Finalize 5–8 keywords aligned with journal indexing.');
end

if ~referencesReady
    Findings = addFinding(Findings, 'MCRA-F023', 'MAJOR', 'References', ...
        'References are not yet populated with final bibliographic entries.', ...
        'Build the final reference list before pre-submission.');
end

%% Citations / tables / figures

citationPatterns = {
    '\([A-Z][A-Za-z\-]+,\s*\d{4}\)', ...
    '\[[0-9]+\]', ...
    'doi:', ...
    'https?://'
};

citationHits = 0;
for k = 1:numel(citationPatterns)
    citationHits = citationHits + numel(regexp(txt, citationPatterns{k}, 'match'));
end

Tchecks = addCheck(Tchecks, 'MCRA-024', 'At least some citation/reference markers present', ...
    citationHits > 0, sprintf('citation_like_hits=%d', citationHits));

if citationHits == 0
    Findings = addFinding(Findings, 'MCRA-F024', 'MAJOR', 'References', ...
        'No citation-like markers were detected in the MASTER.', ...
        'Add in-text citations and bibliography entries for model, collector curve, drying kinetics, optimization, and emission/cost factors.');
end

tableTokenCount = countLiteral(txt, 'TABLE_') + countLiteral(txt, 'MANUSCRIPT_TABLE') + countLiteral(txt, 'SUPP_TABLE');
figureTokenCount = countLiteral(txt, 'FIG_') + countLiteral(txt, 'Figure ') + countLiteral(txt, 'figure ');

Tchecks = addCheck(Tchecks, 'MCRA-025', 'Table placeholders/tokens detected for follow-up', ...
    tableTokenCount > 0, sprintf('table_token_count=%d', tableTokenCount));

Tchecks = addCheck(Tchecks, 'MCRA-026', 'Figure placeholders/tokens detected for follow-up', ...
    figureTokenCount > 0, sprintf('figure_token_count=%d', figureTokenCount));

if tableTokenCount > 0
    Findings = addFinding(Findings, 'MCRA-F025', 'MINOR', 'Tables', ...
        sprintf('Table tokens/placeholders detected: %d.', tableTokenCount), ...
        'Confirm whether table Markdown is embedded or still only referenced by filename.');
end

if figureTokenCount > 0
    Findings = addFinding(Findings, 'MCRA-F026', 'MAJOR', 'Figures', ...
        sprintf('Figure tokens/placeholders detected: %d.', figureTokenCount), ...
        'Replace figure placeholders with final captions and figure-callout strategy.');
end

%% Repetition / duplication signals

dupPhrases = [
    "R1_solution_3 showed a 43.07% reduction"
    "R1_solution_9 showed a lower relative reduction of 31.31%"
    "Final cost or CO2 claims"
    "computed nondominated set"
    "historical reference"
];

for k = 1:numel(dupPhrases)
    phrase = char(dupPhrases(k));
    n = countLiteral(txt, phrase);
    Tchecks = addCheck(Tchecks, sprintf('MCRA-%03d', 26+k), ...
        sprintf('Duplication scan phrase: %s', phrase), ...
        n <= 8, sprintf('count=%d', n));

    if n > 8
        Findings = addFinding(Findings, sprintf('MCRA-F%03d', 26+k), 'MINOR', 'Redundancy', ...
            sprintf('Phrase appears frequently: "%s" count=%d.', phrase, n), ...
            'Review whether repeated cautionary language can be consolidated.');
    end
end

% Known awkward duplicated local wording from hybrid-vs-gasLP section.
awkwardHybridSentence = 'R1_solution_3 showed a 43.07% reduction, while For R1_solution_9';
hasAwkwardHybrid = contains(txtStr, awkwardHybridSentence);

Tchecks = addCheck(Tchecks, 'MCRA-032', 'No known awkward hybrid baseline sentence remains', ...
    ~hasAwkwardHybrid, sprintf('present=%d', hasAwkwardHybrid));

if hasAwkwardHybrid
    Findings = addFinding(Findings, 'MCRA-F032', 'MINOR', 'Style/grammar', ...
        'Known awkward sentence remains in hybrid versus gas-LPG baseline paragraph.', ...
        'Revise the local transition around R1_solution_3 and R1_solution_9.');
end

%% Conceptual guardrails

globalOptClaim = hasUnsupportedGlobalOptimumClaim(txt);
globalParetoClaim = hasUnsupportedGlobalParetoClaim(txt);
statRobustClaim = hasUnsupportedStatisticalRobustnessClaim(txt);

Tchecks = addCheck(Tchecks, 'MCRA-033', 'No unsupported global optimality claim', ...
    ~globalOptClaim, sprintf('present=%d', globalOptClaim));

Tchecks = addCheck(Tchecks, 'MCRA-034', 'No unsupported global Pareto-front claim', ...
    ~globalParetoClaim, sprintf('present=%d', globalParetoClaim));

Tchecks = addCheck(Tchecks, 'MCRA-035', 'No unsupported statistical robustness claim', ...
    ~statRobustClaim, sprintf('present=%d', statRobustClaim));

Tchecks = addCheck(Tchecks, 'MCRA-036', 'Computed nondominated set wording retained', ...
    contains(txtStr, 'computed nondominated set'), ...
    sprintf('count=%d', countLiteral(txt, 'computed nondominated set')));

Tchecks = addCheck(Tchecks, 'MCRA-037', 'H2 historical-reference framing retained', ...
    contains(lower(txtStr), 'h2') && contains(lower(txtStr), 'historical reference'), ...
    sprintf('H2_count=%d historical_reference_count=%d', countLiteral(txt,'H2'), countLiteral(lower(txt),'historical reference')));

Tchecks = addCheck(Tchecks, 'MCRA-038', '2-SAH sensitivity caveat retained', ...
    contains(txtStr, '2-SAH') && contains(lower(txtStr), 'sensitivity'), ...
    sprintf('2SAH_count=%d sensitivity_count=%d', countLiteral(txt,'2-SAH'), countLiteral(lower(txt),'sensitivity')));

Tchecks = addCheck(Tchecks, 'MCRA-039', 'Solar-only exclusion retained', ...
    contains(lower(txtStr), 'solar-only') && contains(lower(txtStr), 'excluded'), ...
    sprintf('solar_only_count=%d excluded_count=%d', countLiteral(lower(txt),'solar-only'), countLiteral(lower(txt),'excluded')));

Tchecks = addCheck(Tchecks, 'MCRA-040', 'Fan-power/pressure-drop limitation retained', ...
    contains(lower(txtStr), 'fan-power') || contains(lower(txtStr), 'fan power') || contains(lower(txtStr), 'pressure-drop'), ...
    sprintf('fan_power_count=%d pressure_drop_count=%d', countLiteral(lower(txt),'fan power')+countLiteral(lower(txt),'fan-power'), countLiteral(lower(txt),'pressure-drop')));

Tchecks = addCheck(Tchecks, 'MCRA-041', 'Cost/CO2 provisional traceability retained', ...
    contains(txtStr, 'PROVISIONAL_FOR_CODE_VALIDATION'), ...
    sprintf('count=%d', countLiteral(txt, 'PROVISIONAL_FOR_CODE_VALIDATION')));

%% Readiness decision logic

criticalFailed = failedBySeverity(Tchecks, ["MCRA-004"]);
majorOpen = nPending > 0 || expectedContentCount > 0 || expectedFigureCount > 0 || ...
    candidateKeywordsCount > 0 || requiredReferencesCount > 0 || ...
    ~abstractReady || ~referencesReady || citationHits == 0;

Tchecks = addCheck(Tchecks, 'MCRA-042', 'No critical structural blocker remains', ...
    ~criticalFailed, sprintf('criticalFailed=%d', criticalFailed));

Tchecks = addCheck(Tchecks, 'MCRA-043', 'No major content-readiness blocker remains', ...
    ~majorOpen, sprintf('majorOpen=%d', majorOpen));

Tchecks = addCheck(Tchecks, 'MCRA-044', 'No GA executed by this audit', ...
    true, 'READ_ONLY text audit');

Tchecks = addCheck(Tchecks, 'MCRA-045', 'No drying model executed by this audit', ...
    true, 'READ_ONLY text audit');

Tchecks = addCheck(Tchecks, 'MCRA-046', 'MASTER was not modified by this audit', ...
    true, 'READ_ONLY no write to MASTER');

failed = Tchecks(~Tchecks.pass, :);

if criticalFailed
    diagnosis = 'MASTER_MANUSCRIPT_CONTENT_READINESS_AUDIT_CRITICAL_REVIEW_REQUIRED';
    decision = 'STOP_CONTENT_EDITING_UNTIL_STRUCTURE_FIXED';
elseif majorOpen
    diagnosis = 'MASTER_MANUSCRIPT_CONTENT_READINESS_AUDIT_REVIEW_REQUIRED';
    decision = 'CONTENT_COMPLETION_REQUIRED_BEFORE_PRE_SUBMISSION';
elseif isempty(failed)
    diagnosis = 'MASTER_MANUSCRIPT_CONTENT_READINESS_AUDIT_PASS';
    decision = 'MASTER_READY_FOR_EDITORIAL_POLISHING';
else
    diagnosis = 'MASTER_MANUSCRIPT_CONTENT_READINESS_AUDIT_MINOR_REVIEW_REQUIRED';
    decision = 'MINOR_EDITORIAL_REVIEW_BEFORE_POLISHING';
end

%% Write files

writetable(Tchecks, checksPath);
writetable(Findings, findingsPath);

fid = fopen(reportPath, 'w');

fprintf(fid, '# MASTER_MANUSCRIPT_CONTENT_READINESS_AUDIT_v96z report\n\n');

fprintf(fid, '## Identifier\n\n');
fprintf(fid, '`MASTER-MANUSCRIPT-CONTENT-READINESS-AUDIT-v96z-001`\n\n');

fprintf(fid, '## Mode\n\n');
fprintf(fid, '`READ_ONLY`\n\n');

fprintf(fid, '## Diagnosis\n\n');
fprintf(fid, '`%s`\n\n', diagnosis);

fprintf(fid, '## Decision\n\n');
fprintf(fid, '`%s`\n\n', decision);

fprintf(fid, '## Files\n\n');
fprintf(fid, '- MASTER: `%s`\n', masterPath);
fprintf(fid, '- Checks: `%s`\n', checksPath);
fprintf(fid, '- Findings: `%s`\n', findingsPath);
fprintf(fid, '- Section inventory: `%s`\n\n', sectionInventoryPath);

fprintf(fid, '## Executive summary\n\n');

fprintf(fid, '- Route-B structure valid: `%d`\n', routeBOK);
fprintf(fid, '- Pending markers: `%d`\n', nPending);
fprintf(fid, '- Expected-content scaffolding markers: `%d`\n', expectedContentCount);
fprintf(fid, '- Expected-figure scaffolding markers: `%d`\n', expectedFigureCount);
fprintf(fid, '- Citation-like markers: `%d`\n', citationHits);
fprintf(fid, '- Table tokens/placeholders: `%d`\n', tableTokenCount);
fprintf(fid, '- Figure tokens/placeholders: `%d`\n\n', figureTokenCount);

fprintf(fid, '## Findings\n\n');

if isempty(Findings)
    fprintf(fid, 'None.\n\n');
else
    fprintf(fid, '| id | severity | category | finding | recommendation |\n');
    fprintf(fid, '|---|---|---|---|---|\n');
    for i = 1:height(Findings)
        fprintf(fid, '| `%s` | `%s` | %s | %s | %s |\n', ...
            Findings.id(i), Findings.severity(i), Findings.category(i), ...
            Findings.finding(i), Findings.recommendation(i));
    end
    fprintf(fid, '\n');
end

fprintf(fid, '## Failed checks\n\n');

if isempty(failed)
    fprintf(fid, 'None.\n\n');
else
    fprintf(fid, '| id | check | evidence |\n');
    fprintf(fid, '|---|---|---|\n');
    for i = 1:height(failed)
        fprintf(fid, '| `%s` | %s | `%s` |\n', ...
            failed.id(i), failed.check(i), failed.evidence(i));
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

%% Console summary

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Decision:  %s\n', decision);
fprintf('Report:    %s\n', reportPath);
fprintf('Checks:    %s\n', checksPath);
fprintf('Findings:  %s\n', findingsPath);
fprintf('Inventory: %s\n', sectionInventoryPath);

if ~isempty(failed)
    fprintf('\nFailed checks:\n');
    disp(failed(:, {'id','check','evidence'}));
end

fprintf('\nMASTER_MANUSCRIPT_CONTENT_READINESS_AUDIT_DONE\n');

%% Local functions

function T = addCheck(T,id,check,pass,evidence)
    T = [T; table(string(id), string(check), logical(pass), string(evidence), ...
        'VariableNames', {'id','check','pass','evidence'})];
end

function F = addFinding(F,id,severity,category,finding,recommendation)
    F = [F; table(string(id), string(severity), string(category), string(finding), string(recommendation), ...
        'VariableNames', {'id','severity','category','finding','recommendation'})];
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

function idx = findHeadingExact(Headings, rawHeading)
    idx = find(strcmp(strtrim(Headings.raw), strtrim(string(rawHeading))));
end

function p = firstChar(Headings, idx)
    if isempty(idx)
        p = NaN;
    else
        p = Headings.charpos(idx(1));
    end
end

function s = headingSummary(Headings, idx)
    if isempty(idx)
        s = "NOT_DETECTED";
        return;
    end
    parts = strings(numel(idx),1);
    for k = 1:numel(idx)
        ii = idx(k);
        parts(k) = sprintf('line=%d char=%d level=%d raw=%s', ...
            Headings.line(ii), Headings.charpos(ii), Headings.level(ii), Headings.raw(ii));
    end
    s = join(parts, ' || ');
end

function p = firstLiteralPos(txt, phrase)
    pos = strfind(txt, phrase);
    if isempty(pos)
        p = NaN;
    else
        p = pos(1);
    end
end

function segment = sectionSegmentByHeading(txt, Headings, rawHeading)
    idx = findHeadingExact(Headings, rawHeading);
    if isempty(idx)
        segment = '';
        return;
    end

    i = idx(1);
    startPos = Headings.charpos(i);

    endPos = strlength(string(txt)) + 1;
    for j = i+1:height(Headings)
        if Headings.level(j) <= Headings.level(i)
            endPos = Headings.charpos(j);
            break;
        end
    end

    segment = char(extractBetween(string(txt), startPos, endPos-1));
end

function body = stripHeadingLine(seg)
    lines = splitlines(string(seg));
    if numel(lines) <= 1
        body = '';
    else
        body = char(join(lines(2:end), newline));
    end
end

function n = countListItems(seg)
    lines = splitlines(string(seg));
    n = 0;
    for i = 1:numel(lines)
        li = strtrim(lines(i));
        if startsWith(li, "- ") || startsWith(li, "* ") || ~isempty(regexp(char(li), '^\d+\.\s+', 'once'))
            n = n + 1;
        end
    end
end

function out = strjoin(cellArray, delimiter)
    if isempty(cellArray)
        out = '';
        return;
    end
    out = char(cellArray{1});
    for i = 2:numel(cellArray)
        out = [out delimiter char(cellArray{i})]; %#ok<AGROW>
    end
end

function pending = detectPendingTopSections(txt, Headings)
    pending = strings(0,1);
    for i = 1:height(Headings)
        if Headings.level(i) == 1
            startPos = Headings.charpos(i);
            endPos = strlength(string(txt)) + 1;
            for j = i+1:height(Headings)
                if Headings.level(j) <= 1
                    endPos = Headings.charpos(j);
                    break;
                end
            end
            seg = char(extractBetween(string(txt), startPos, endPos-1));
            if contains(string(seg), '`STATUS: PENDING`')
                pending(end+1,1) = Headings.raw(i); %#ok<AGROW>
            end
        end
    end
end

function inv = buildSectionInventory(txt, Headings)
    ids = strings(height(Headings),1);
    raw = strings(height(Headings),1);
    level = zeros(height(Headings),1);
    line = zeros(height(Headings),1);
    charpos = zeros(height(Headings),1);
    bodyChars = zeros(height(Headings),1);
    pending = false(height(Headings),1);

    for i = 1:height(Headings)
        ids(i) = sprintf('H%03d', i);
        raw(i) = Headings.raw(i);
        level(i) = Headings.level(i);
        line(i) = Headings.line(i);
        charpos(i) = Headings.charpos(i);

        startPos = Headings.charpos(i);
        endPos = strlength(string(txt)) + 1;
        for j = i+1:height(Headings)
            if Headings.level(j) <= Headings.level(i)
                endPos = Headings.charpos(j);
                break;
            end
        end

        seg = char(extractBetween(string(txt), startPos, endPos-1));
        bodyChars(i) = strlength(string(stripHeadingLine(seg)));
        pending(i) = contains(string(seg), '`STATUS: PENDING`');
    end

    inv = table(ids, raw, level, line, charpos, bodyChars, pending, ...
        'VariableNames', {'id','heading','level','line','charpos','bodyChars','hasPending'});
end

function tf = failedBySeverity(Tchecks, ids)
    tf = false;
    for i = 1:numel(ids)
        idx = strcmp(Tchecks.id, ids(i));
        if any(idx) && any(~Tchecks.pass(idx))
            tf = true;
        end
    end
end

function present = hasUnsupportedGlobalOptimumClaim(txt)
    s = lower(string(normalizeNewlines(txt)));
    lines = splitlines(s);
    present = false;
    prohibited = ["global optimum", "globally optimal", "global optimality"];
    protective = ["do not", "does not", "no claim", "not claim", "not as", ...
        "not be interpreted", "should not", "avoid", "prohibited", ...
        "restriction", "instead of", "proof of", "not proof", "no prohibited"];
    for i = 1:numel(lines)
        li = strtrim(lines(i));
        hasBad = false;
        for k = 1:numel(prohibited)
            if contains(li, prohibited(k)), hasBad = true; end
        end
        if ~hasBad, continue; end
        isProtected = false;
        for k = 1:numel(protective)
            if contains(li, protective(k)), isProtected = true; end
        end
        if ~isProtected
            present = true;
            return;
        end
    end
end

function present = hasUnsupportedGlobalParetoClaim(txt)
    s = lower(string(normalizeNewlines(txt)));
    lines = splitlines(s);
    present = false;
    prohibited = ["global pareto front", "complete pareto front", "complete pareto-front characterization"];
    protective = ["do not", "does not", "no claim", "not claim", "not as", ...
        "not be interpreted", "should not", "avoid", "prohibited", ...
        "restriction", "instead of", "use computed nondominated set", "no prohibited"];
    for i = 1:numel(lines)
        li = strtrim(lines(i));
        hasBad = false;
        for k = 1:numel(prohibited)
            if contains(li, prohibited(k)), hasBad = true; end
        end
        if ~hasBad, continue; end
        isProtected = false;
        for k = 1:numel(protective)
            if contains(li, protective(k)), isProtected = true; end
        end
        if ~isProtected
            present = true;
            return;
        end
    end
end

function present = hasUnsupportedStatisticalRobustnessClaim(txt)
    s = lower(string(normalizeNewlines(txt)));
    lines = splitlines(s);
    present = false;
    prohibited = ["statistically robust", "statistical robustness was demonstrated", ...
        "robust across independent seeds", "robustness across independent seeds was demonstrated"];
    protective = ["does not establish", "does not claim", "no claim", "additional independent", ...
        "would be required", "not as proof", "should not"];
    for i = 1:numel(lines)
        li = strtrim(lines(i));
        hasBad = false;
        for k = 1:numel(prohibited)
            if contains(li, prohibited(k)), hasBad = true; end
        end
        if ~hasBad, continue; end
        isProtected = false;
        for k = 1:numel(protective)
            if contains(li, protective(k)), isProtected = true; end
        end
        if ~isProtected
            present = true;
            return;
        end
    end
end
