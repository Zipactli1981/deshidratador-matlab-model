%% diagnose_master_section_map_after_fix1_v96z.m
% 9.6z-audit-c-diagnostic
% MASTER-SECTION-MAP-DIAGNOSTIC-AFTER-FIX1-001
% READ_ONLY
%
% Purpose:
%   Diagnose the real MASTER manuscript structure after fix1 without
%   modifying MASTER_manuscript_v01.md.
%
% This script:
%   - Reads MASTER only.
%   - Detects clean Markdown headings.
%   - Detects glued headings, including "20###".
%   - Locates Discussion, Limitations, Conclusions, References.
%   - Counts internal block keys.
%   - Evaluates likely section-order failure cause.
%   - Writes diagnostic report and CSV checks only.
%
% This script does NOT:
%   - Modify MASTER.
%   - Restore backup.
%   - Reorder sections.
%   - Generate patch fix2.
%   - Run GA.
%   - Run the drying model.

clear; clc;

fprintf('\n=== MASTER SECTION MAP DIAGNOSTIC AFTER FIX1 v96z ===\n');

%% Paths

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
    'MASTER_SECTION_MAP_DIAGNOSTIC_AFTER_FIX1_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_SECTION_MAP_DIAGNOSTIC_AFTER_FIX1_v96z_Tchecks.csv');

headingsPath = fullfile(reviewDir, ...
    'MASTER_SECTION_MAP_DIAGNOSTIC_AFTER_FIX1_v96z_headings.txt');

%% Helpers

addCheck = @(T,id,check,pass,evidence) [T; ...
    table(string(id), string(check), logical(pass), string(evidence), ...
    'VariableNames', {'id','check','pass','evidence'})];

Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

%% Read MASTER

Tchecks = addCheck(Tchecks, 'DIAFX1-01', 'MASTER exists', ...
    exist(masterPath, 'file') == 2, masterPath);

if exist(masterPath, 'file') ~= 2
    writetable(Tchecks, checksPath);
    error('MASTER not found: %s', masterPath);
end

txt = fileread(masterPath);
txt = strrep(txt, char([13 10]), newline);
txt = strrep(txt, char(13), newline);

Tchecks = addCheck(Tchecks, 'DIAFX1-02', 'MASTER read successfully', ...
    strlength(string(txt)) > 0, sprintf('chars=%d', strlength(string(txt))));

%% Split lines and build line start char positions

lines = splitlines(string(txt));
nLines = numel(lines);

lineStart = zeros(nLines,1);
pos = 1;
for i = 1:nLines
    lineStart(i) = pos;
    pos = pos + strlength(lines(i)) + 1; % + newline
end

%% Detect clean Markdown headings

% Clean heading: line starts with 1-6 hashes followed by space.
cleanHeadingRows = {};
for i = 1:nLines
    li = char(lines(i));
    tok = regexp(li, '^(#{1,6})\s+(.+?)\s*$', 'tokens', 'once');
    if ~isempty(tok)
        cleanHeadingRows = [cleanHeadingRows; ...
            {i, lineStart(i), string(tok{1}), strlength(string(tok{1})), string(tok{2}), string(li)}]; %#ok<AGROW>
    end
end

if isempty(cleanHeadingRows)
    Headings = table([], [], strings(0,1), [], strings(0,1), strings(0,1), ...
        'VariableNames', {'line','charpos','hashes','level','title','raw'});
else
    Headings = cell2table(cleanHeadingRows, ...
        'VariableNames', {'line','charpos','hashes','level','title','raw'});
    Headings.line = cell2mat(Headings.line);
    Headings.charpos = cell2mat(Headings.charpos);
    Headings.level = cell2mat(Headings.level);
end

Tchecks = addCheck(Tchecks, 'DIAFX1-03', 'Clean Markdown headings detected', ...
    height(Headings) > 0, sprintf('clean_headings=%d', height(Headings)));

%% Detect glued headings

% Any # heading not preceded by newline or beginning of file.
gluedCriticalPattern = '[^\n]#{2,6}\s*(Discussion|Limitations|Conclusions|References)';
gluedAnyPattern = '[^\n]#{1,6}\s+[^\n]+';

gluedCrit = regexp(txt, gluedCriticalPattern, 'match');
gluedAny  = regexp(txt, gluedAnyPattern, 'match');

Tchecks = addCheck(Tchecks, 'DIAFX1-04', 'No glued critical headings', ...
    isempty(gluedCrit), strjoin(cellstr(string(gluedCrit)), ' | '));

Tchecks = addCheck(Tchecks, 'DIAFX1-05', 'No glued headings anywhere', ...
    isempty(gluedAny), strjoin(cellstr(string(gluedAny)), ' | '));

n20hash = numel(regexp(txt, '20#{1,6}', 'match'));
Tchecks = addCheck(Tchecks, 'DIAFX1-06', 'No residual 20# heading prefixes', ...
    n20hash == 0, sprintf('20#_prefix_count=%d', n20hash));

%% Locate key headings by clean heading titles

titleNorm = lower(strtrim(Headings.title));

findTitleExact = @(name) find(strcmpi(strtrim(Headings.title), name));

idxDiscussion   = findTitleExact('Discussion');
idxLimitations  = findTitleExact('Limitations');
idxConclusions  = findTitleExact('Conclusions');
idxReferences   = findTitleExact('References');
idxNomenclature = findTitleExact('Nomenclature'); %#ok<NASGU>
idxSupp         = findTitleExact('Supplementary material'); %#ok<NASGU>

% Also detect numbered headings containing the section name.
idxResultsNumbered = find(contains(titleNorm, 'results and discussion'));
idxLimitNum        = find(contains(titleNorm, 'limitations')); %#ok<NASGU>
idxConclNum        = find(contains(titleNorm, 'conclusions')); %#ok<NASGU>
idxRefNum          = find(contains(titleNorm, 'references')); %#ok<NASGU>
idxNomNum          = find(contains(titleNorm, 'nomenclature')); %#ok<NASGU>
idxSuppNum         = find(contains(titleNorm, 'supplementary material')); %#ok<NASGU>

%% Utility to summarize heading positions

discSummary = localHeadingSummary(Headings, idxDiscussion);
limSummary  = localHeadingSummary(Headings, idxLimitations);
concSummary = localHeadingSummary(Headings, idxConclusions);
refSummary  = localHeadingSummary(Headings, idxReferences);

Tchecks = addCheck(Tchecks, 'DIAFX1-07', 'Clean Discussion heading count', ...
    numel(idxDiscussion) == 1, sprintf('count=%d | %s', numel(idxDiscussion), discSummary));

Tchecks = addCheck(Tchecks, 'DIAFX1-08', 'Clean Limitations heading count', ...
    numel(idxLimitations) == 1, sprintf('count=%d | %s', numel(idxLimitations), limSummary));

Tchecks = addCheck(Tchecks, 'DIAFX1-09', 'Clean Conclusions heading count', ...
    numel(idxConclusions) == 1, sprintf('count=%d | %s', numel(idxConclusions), concSummary));

Tchecks = addCheck(Tchecks, 'DIAFX1-10', 'Clean References heading count', ...
    numel(idxReferences) == 1, sprintf('count=%d | %s', numel(idxReferences), refSummary));

%% Detect heading levels

if numel(idxDiscussion) == 1
    discLevel = Headings.level(idxDiscussion);
else
    discLevel = NaN;
end

if numel(idxLimitations) == 1
    limLevel = Headings.level(idxLimitations);
else
    limLevel = NaN;
end

if numel(idxConclusions) == 1
    concLevel = Headings.level(idxConclusions);
else
    concLevel = NaN;
end

Tchecks = addCheck(Tchecks, 'DIAFX1-11', 'Discussion heading level is ###', ...
    isequal(discLevel, 3), sprintf('level=%s', mat2str(discLevel)));

Tchecks = addCheck(Tchecks, 'DIAFX1-12', 'Limitations heading level is ###', ...
    isequal(limLevel, 3), sprintf('level=%s', mat2str(limLevel)));

Tchecks = addCheck(Tchecks, 'DIAFX1-13', 'Conclusions heading level is ###', ...
    isequal(concLevel, 3), sprintf('level=%s', mat2str(concLevel)));

%% Minimum order check by char positions

posResults = localFirstChar(Headings, idxResultsNumbered);
posDisc    = localFirstChar(Headings, idxDiscussion);
posLim     = localFirstChar(Headings, idxLimitations);
posConc    = localFirstChar(Headings, idxConclusions);
posRef     = localFirstChar(Headings, idxReferences);

minimumOrderValid = all(~isnan([posResults posDisc posLim posConc posRef])) && ...
    posResults < posDisc && posDisc < posLim && posLim < posConc && posConc < posRef;

Tchecks = addCheck(Tchecks, 'DIAFX1-14', ...
    'Minimum section order valid: Results -> Discussion -> Limitations -> Conclusions -> References', ...
    minimumOrderValid, ...
    sprintf('Results=%g | Discussion=%g | Limitations=%g | Conclusions=%g | References=%g', ...
    posResults, posDisc, posLim, posConc, posRef));

%% Placeholder detection

placeholderLimitations = regexp(txt, '# 8\. Limitations\s+`STATUS:\s*PENDING`', 'once');
placeholderConclusions = regexp(txt, '# 9\. Conclusions\s+`STATUS:\s*PENDING`', 'once');

Tchecks = addCheck(Tchecks, 'DIAFX1-15', 'Placeholder # 8 Limitations still present', ...
    ~isempty(placeholderLimitations), sprintf('charpos=%s', mat2str(placeholderLimitations)));

Tchecks = addCheck(Tchecks, 'DIAFX1-16', 'Placeholder # 9 Conclusions still present', ...
    ~isempty(placeholderConclusions), sprintf('charpos=%s', mat2str(placeholderConclusions)));

%% Internal key counts

keyDiscussion = 'The formal R1 optimization and the subsequent sensitivity and baseline analyses indicate';
keyLimitations = 'Several limitations must be considered when interpreting the optimization and baseline-comparison results';
keyConclusions = 'This study developed a controlled multiobjective optimization and post-processing workflow';

nKeyDiscussion = numel(strfind(txt, keyDiscussion));
nKeyLimitations = numel(strfind(txt, keyLimitations));
nKeyConclusions = numel(strfind(txt, keyConclusions));

Tchecks = addCheck(Tchecks, 'DIAFX1-17', 'Discussion internal key count equals one', ...
    nKeyDiscussion == 1, sprintf('count=%d', nKeyDiscussion));

Tchecks = addCheck(Tchecks, 'DIAFX1-18', 'Limitations internal key count equals one', ...
    nKeyLimitations == 1, sprintf('count=%d', nKeyLimitations));

Tchecks = addCheck(Tchecks, 'DIAFX1-19', 'Conclusions internal key count equals one', ...
    nKeyConclusions == 1, sprintf('count=%d', nKeyConclusions));

%% Detect block positions by internal keys

posKeyDiscussion = strfind(txt, keyDiscussion);
posKeyLimitations = strfind(txt, keyLimitations);
posKeyConclusions = strfind(txt, keyConclusions);

if isempty(posKeyDiscussion), posKeyDiscussion = NaN; else, posKeyDiscussion = posKeyDiscussion(1); end
if isempty(posKeyLimitations), posKeyLimitations = NaN; else, posKeyLimitations = posKeyLimitations(1); end
if isempty(posKeyConclusions), posKeyConclusions = NaN; else, posKeyConclusions = posKeyConclusions(1); end

Tchecks = addCheck(Tchecks, 'DIAFX1-20', 'Internal key order: Discussion -> Limitations -> Conclusions', ...
    all(~isnan([posKeyDiscussion posKeyLimitations posKeyConclusions])) && ...
    posKeyDiscussion < posKeyLimitations && posKeyLimitations < posKeyConclusions, ...
    sprintf('DiscussionKey=%g | LimitationsKey=%g | ConclusionsKey=%g', ...
    posKeyDiscussion, posKeyLimitations, posKeyConclusions));

%% Detect current block order after References area

if ~isnan(posRef)
    blocksAfterReferences = [posDisc posLim posConc] > posRef;
    Tchecks = addCheck(Tchecks, 'DIAFX1-21', ...
        'Developed Discussion/Limitations/Conclusions headings are before References', ...
        all([posDisc posLim posConc] < posRef), ...
        sprintf('DiscussionAfterRef=%d | LimitationsAfterRef=%d | ConclusionsAfterRef=%d', ...
        blocksAfterReferences(1), blocksAfterReferences(2), blocksAfterReferences(3)));
else
    Tchecks = addCheck(Tchecks, 'DIAFX1-21', ...
        'Developed Discussion/Limitations/Conclusions headings are before References', ...
        false, 'References not detected as clean heading');
end

%% Write headings report

fid = fopen(headingsPath, 'w');
fprintf(fid, 'MASTER SECTION MAP DIAGNOSTIC AFTER FIX1 v96z - HEADINGS\n\n');
fprintf(fid, 'MASTER: %s\n\n', masterPath);

for i = 1:height(Headings)
    fprintf(fid, '%04d | line %05d | char %08d | level %d | %s\n', ...
        i, Headings.line(i), Headings.charpos(i), Headings.level(i), Headings.raw(i));
end

fclose(fid);

%% Write Markdown report

failed = Tchecks(~Tchecks.pass, :);

fid = fopen(reportPath, 'w');

fprintf(fid, '# MASTER_SECTION_MAP_DIAGNOSTIC_AFTER_FIX1_v96z report\n\n');

fprintf(fid, '## Identifier\n\n');
fprintf(fid, '`MASTER-SECTION-MAP-DIAGNOSTIC-AFTER-FIX1-001`\n\n');

fprintf(fid, '## Mode\n\n');
fprintf(fid, '`READ_ONLY`\n\n');

fprintf(fid, '## Diagnosis\n\n');

if isempty(failed)
    diagnosis = 'MASTER_SECTION_MAP_DIAGNOSTIC_AFTER_FIX1_PASS';
else
    diagnosis = 'MASTER_SECTION_MAP_DIAGNOSTIC_AFTER_FIX1_REVIEW_REQUIRED';
end

fprintf(fid, '`%s`\n\n', diagnosis);

fprintf(fid, '## Files\n\n');
fprintf(fid, '- MASTER: `%s`\n', masterPath);
fprintf(fid, '- Headings report: `%s`\n', headingsPath);
fprintf(fid, '- Checks CSV: `%s`\n\n', checksPath);

fprintf(fid, '## Key positions\n\n');
fprintf(fid, '| item | char position | evidence |\n');
fprintf(fid, '|---|---:|---|\n');
fprintf(fid, '| Results and discussion | %.0f | `%s` |\n', posResults, localHeadingSummary(Headings, idxResultsNumbered));
fprintf(fid, '| Discussion | %.0f | `%s` |\n', posDisc, discSummary);
fprintf(fid, '| Limitations | %.0f | `%s` |\n', posLim, limSummary);
fprintf(fid, '| Conclusions | %.0f | `%s` |\n', posConc, concSummary);
fprintf(fid, '| References | %.0f | `%s` |\n\n', posRef, refSummary);

fprintf(fid, '## Internal key positions\n\n');
fprintf(fid, '| block | char position | count |\n');
fprintf(fid, '|---|---:|---:|\n');
fprintf(fid, '| Discussion key | %.0f | %d |\n', posKeyDiscussion, nKeyDiscussion);
fprintf(fid, '| Limitations key | %.0f | %d |\n', posKeyLimitations, nKeyLimitations);
fprintf(fid, '| Conclusions key | %.0f | %d |\n\n', posKeyConclusions, nKeyConclusions);

fprintf(fid, '## Placeholder status\n\n');
fprintf(fid, '| placeholder | present | char position |\n');
fprintf(fid, '|---|---:|---:|\n');
fprintf(fid, '| # 8. Limitations pending | %d | %s |\n', ~isempty(placeholderLimitations), mat2str(placeholderLimitations));
fprintf(fid, '| # 9. Conclusions pending | %d | %s |\n\n', ~isempty(placeholderConclusions), mat2str(placeholderConclusions));

fprintf(fid, '## Glued heading evidence\n\n');
fprintf(fid, '- Glued critical headings: `%s`\n', strjoin(cellstr(string(gluedCrit)), ' | '));
fprintf(fid, '- Glued headings anywhere: `%s`\n', strjoin(cellstr(string(gluedAny)), ' | '));
fprintf(fid, '- Residual `20#` prefix count: `%d`\n\n', n20hash);

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

fprintf(fid, '## Interpretation guide\n\n');
fprintf(fid, 'If internal keys are present once but heading/order checks fail, the problem is structural Markdown assembly rather than missing technical content.\n\n');
fprintf(fid, 'If developed Discussion, Limitations, or Conclusions are after References, fix1 inserted blocks in the wrong manuscript region.\n\n');
fprintf(fid, 'If placeholders remain, a future fix must decide whether to replace placeholders or remove them after relocating developed blocks.\n\n');
fprintf(fid, 'If residual `20###` or glued headings remain, a future fix must normalize line breaks globally before section-order validation.\n\n');

fprintf(fid, '## Next-step recommendation\n\n');

if ~minimumOrderValid
    fprintf(fid, '`DO_NOT_PATCH_BLINDLY`\n\n');
    fprintf(fid, 'Recommended next step: inspect this diagnostic report and decide whether to restore the pre-fix1 backup before applying a conservative fix2.\n\n');
else
    fprintf(fid, '`READY_FOR_STANDARD_MASTER_AUDIT`\n\n');
end

fclose(fid);

%% Write checks

writetable(Tchecks, checksPath);

%% Console summary

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Report:   %s\n', reportPath);
fprintf('Checks:   %s\n', checksPath);
fprintf('Headings: %s\n', headingsPath);

if ~isempty(failed)
    fprintf('\nFailed checks:\n');
    disp(failed(:, {'id','check','evidence'}));
end

fprintf('\nMASTER_SECTION_MAP_DIAGNOSTIC_AFTER_FIX1_DONE\n');

%% Local functions

function s = localHeadingSummary(Headings, idx)
    if isempty(idx)
        s = "NOT_DETECTED";
        return;
    end

    parts = strings(numel(idx),1);
    for k = 1:numel(idx)
        ii = idx(k);
        parts(k) = sprintf('line=%d char=%d level=%d raw=%s', ...
            Headings.line(ii), Headings.charpos(ii), ...
            Headings.level(ii), Headings.raw(ii));
    end
    s = strjoin(cellstr(parts), ' || ');
end

function p = localFirstChar(Headings, idx)
    if isempty(idx)
        p = NaN;
    else
        p = Headings.charpos(idx(1));
    end
end
