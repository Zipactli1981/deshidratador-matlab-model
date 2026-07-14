%% diagnose_master_section_map_after_fix1_v96z.m
% 9.6z-audit-c-diagnostic
% MASTER-SECTION-MAP-DIAGNOSTIC-AFTER-FIX1-001
% READ_ONLY
%
% Robust version v2: avoids cell2mat table post-conversion issue.

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

%% Checks table helper
Tchecks = table(strings(0,1), strings(0,1), false(0,1), strings(0,1), ...
    'VariableNames', {'id','check','pass','evidence'});

%% Read MASTER
Tchecks = localAddCheck(Tchecks, 'DIAFX1-01', 'MASTER exists', ...
    exist(masterPath, 'file') == 2, masterPath);

if exist(masterPath, 'file') ~= 2
    writetable(Tchecks, checksPath);
    error('MASTER not found: %s', masterPath);
end

txt = fileread(masterPath);
txt = strrep(txt, char([13 10]), newline);
txt = strrep(txt, char(13), newline);

Tchecks = localAddCheck(Tchecks, 'DIAFX1-02', 'MASTER read successfully', ...
    strlength(string(txt)) > 0, sprintf('chars=%d', strlength(string(txt))));

%% Split lines and line-start char positions
lines = splitlines(string(txt));
nLines = numel(lines);
lineStart = zeros(nLines,1);
pos = 1;
for i = 1:nLines
    lineStart(i) = pos;
    pos = pos + strlength(lines(i)) + 1;
end

%% Detect clean Markdown headings without cell2mat
hLine = [];
hChar = [];
hHashes = strings(0,1);
hLevel = [];
hTitle = strings(0,1);
hRaw = strings(0,1);

for i = 1:nLines
    li = char(lines(i));
    tok = regexp(li, '^(#{1,6})\s+(.+?)\s*$', 'tokens', 'once');
    if ~isempty(tok)
        hLine(end+1,1) = i; %#ok<SAGROW>
        hChar(end+1,1) = lineStart(i); %#ok<SAGROW>
        hHashes(end+1,1) = string(tok{1}); %#ok<SAGROW>
        hLevel(end+1,1) = length(tok{1}); %#ok<SAGROW>
        hTitle(end+1,1) = string(strtrim(tok{2})); %#ok<SAGROW>
        hRaw(end+1,1) = string(li); %#ok<SAGROW>
    end
end

Headings = table(hLine, hChar, hHashes, hLevel, hTitle, hRaw, ...
    'VariableNames', {'line','charpos','hashes','level','title','raw'});

Tchecks = localAddCheck(Tchecks, 'DIAFX1-03', 'Clean Markdown headings detected', ...
    height(Headings) > 0, sprintf('clean_headings=%d', height(Headings)));

%% Detect glued headings
gluedCriticalPattern = '[^\n]#{2,6}\s*(Discussion|Limitations|Conclusions|References)';
gluedAnyPattern = '[^\n]#{1,6}\s+[^\n]+';

gluedCrit = regexp(txt, gluedCriticalPattern, 'match');
gluedAny  = regexp(txt, gluedAnyPattern, 'match');

Tchecks = localAddCheck(Tchecks, 'DIAFX1-04', 'No glued critical headings', ...
    isempty(gluedCrit), localJoinMatches(gluedCrit));
Tchecks = localAddCheck(Tchecks, 'DIAFX1-05', 'No glued headings anywhere', ...
    isempty(gluedAny), localJoinMatches(gluedAny));

n20hash = numel(regexp(txt, '20#{1,6}', 'match'));
Tchecks = localAddCheck(Tchecks, 'DIAFX1-06', 'No residual 20# heading prefixes', ...
    n20hash == 0, sprintf('20#_prefix_count=%d', n20hash));

%% Locate headings
titleTrim = strtrim(Headings.title);
titleNorm = lower(titleTrim);

idxDiscussion   = find(strcmpi(titleTrim, 'Discussion'));
idxLimitations  = find(strcmpi(titleTrim, 'Limitations'));
idxConclusions  = find(strcmpi(titleTrim, 'Conclusions'));
idxReferences   = find(strcmpi(titleTrim, 'References'));

idxResultsNumbered = find(contains(titleNorm, 'results and discussion'));
idxNomenclature = find(contains(titleNorm, 'nomenclature'));
idxSupp = find(contains(titleNorm, 'supplementary material'));

discSummary = localHeadingSummary(Headings, idxDiscussion);
limSummary  = localHeadingSummary(Headings, idxLimitations);
concSummary = localHeadingSummary(Headings, idxConclusions);
refSummary  = localHeadingSummary(Headings, idxReferences);

Tchecks = localAddCheck(Tchecks, 'DIAFX1-07', 'Clean Discussion heading count', ...
    numel(idxDiscussion) == 1, sprintf('count=%d | %s', numel(idxDiscussion), discSummary));
Tchecks = localAddCheck(Tchecks, 'DIAFX1-08', 'Clean Limitations heading count', ...
    numel(idxLimitations) == 1, sprintf('count=%d | %s', numel(idxLimitations), limSummary));
Tchecks = localAddCheck(Tchecks, 'DIAFX1-09', 'Clean Conclusions heading count', ...
    numel(idxConclusions) == 1, sprintf('count=%d | %s', numel(idxConclusions), concSummary));
Tchecks = localAddCheck(Tchecks, 'DIAFX1-10', 'Clean References heading count', ...
    numel(idxReferences) == 1, sprintf('count=%d | %s', numel(idxReferences), refSummary));

%% Heading levels
discLevel = localSingleLevel(Headings, idxDiscussion);
limLevel  = localSingleLevel(Headings, idxLimitations);
concLevel = localSingleLevel(Headings, idxConclusions);

Tchecks = localAddCheck(Tchecks, 'DIAFX1-11', 'Discussion heading level is ###', ...
    isequal(discLevel, 3), sprintf('level=%s', mat2str(discLevel)));
Tchecks = localAddCheck(Tchecks, 'DIAFX1-12', 'Limitations heading level is ###', ...
    isequal(limLevel, 3), sprintf('level=%s', mat2str(limLevel)));
Tchecks = localAddCheck(Tchecks, 'DIAFX1-13', 'Conclusions heading level is ###', ...
    isequal(concLevel, 3), sprintf('level=%s', mat2str(concLevel)));

%% Order check
posResults = localFirstChar(Headings, idxResultsNumbered);
posDisc    = localFirstChar(Headings, idxDiscussion);
posLim     = localFirstChar(Headings, idxLimitations);
posConc    = localFirstChar(Headings, idxConclusions);
posRef     = localFirstChar(Headings, idxReferences);

minimumOrderValid = all(~isnan([posResults posDisc posLim posConc posRef])) && ...
    posResults < posDisc && posDisc < posLim && posLim < posConc && posConc < posRef;

Tchecks = localAddCheck(Tchecks, 'DIAFX1-14', ...
    'Minimum section order valid: Results -> Discussion -> Limitations -> Conclusions -> References', ...
    minimumOrderValid, ...
    sprintf('Results=%g | Discussion=%g | Limitations=%g | Conclusions=%g | References=%g', ...
    posResults, posDisc, posLim, posConc, posRef));

%% Placeholder detection
placeholderLimitations = regexp(txt, '# 8\. Limitations\s+`STATUS:\s*PENDING`', 'once');
placeholderConclusions = regexp(txt, '# 9\. Conclusions\s+`STATUS:\s*PENDING`', 'once');

Tchecks = localAddCheck(Tchecks, 'DIAFX1-15', 'Placeholder # 8 Limitations still present', ...
    ~isempty(placeholderLimitations), sprintf('charpos=%s', mat2str(placeholderLimitations)));
Tchecks = localAddCheck(Tchecks, 'DIAFX1-16', 'Placeholder # 9 Conclusions still present', ...
    ~isempty(placeholderConclusions), sprintf('charpos=%s', mat2str(placeholderConclusions)));

%% Internal key counts
keyDiscussion = 'The formal R1 optimization and the subsequent sensitivity and baseline analyses indicate';
keyLimitations = 'Several limitations must be considered when interpreting the optimization and baseline-comparison results';
keyConclusions = 'This study developed a controlled multiobjective optimization and post-processing workflow';

nKeyDiscussion = numel(strfind(txt, keyDiscussion));
nKeyLimitations = numel(strfind(txt, keyLimitations));
nKeyConclusions = numel(strfind(txt, keyConclusions));

Tchecks = localAddCheck(Tchecks, 'DIAFX1-17', 'Discussion internal key count equals one', ...
    nKeyDiscussion == 1, sprintf('count=%d', nKeyDiscussion));
Tchecks = localAddCheck(Tchecks, 'DIAFX1-18', 'Limitations internal key count equals one', ...
    nKeyLimitations == 1, sprintf('count=%d', nKeyLimitations));
Tchecks = localAddCheck(Tchecks, 'DIAFX1-19', 'Conclusions internal key count equals one', ...
    nKeyConclusions == 1, sprintf('count=%d', nKeyConclusions));

posKeyDiscussion = localFirstMatch(txt, keyDiscussion);
posKeyLimitations = localFirstMatch(txt, keyLimitations);
posKeyConclusions = localFirstMatch(txt, keyConclusions);

Tchecks = localAddCheck(Tchecks, 'DIAFX1-20', 'Internal key order: Discussion -> Limitations -> Conclusions', ...
    all(~isnan([posKeyDiscussion posKeyLimitations posKeyConclusions])) && ...
    posKeyDiscussion < posKeyLimitations && posKeyLimitations < posKeyConclusions, ...
    sprintf('DiscussionKey=%g | LimitationsKey=%g | ConclusionsKey=%g', ...
    posKeyDiscussion, posKeyLimitations, posKeyConclusions));

if ~isnan(posRef)
    Tchecks = localAddCheck(Tchecks, 'DIAFX1-21', ...
        'Developed Discussion/Limitations/Conclusions headings are before References', ...
        all([posDisc posLim posConc] < posRef), ...
        sprintf('DiscussionAfterRef=%d | LimitationsAfterRef=%d | ConclusionsAfterRef=%d', ...
        posDisc > posRef, posLim > posRef, posConc > posRef));
else
    Tchecks = localAddCheck(Tchecks, 'DIAFX1-21', ...
        'Developed Discussion/Limitations/Conclusions headings are before References', ...
        false, 'References not detected as clean heading');
end

%% Write headings report
fid = fopen(headingsPath, 'w');
fprintf(fid, 'MASTER SECTION MAP DIAGNOSTIC AFTER FIX1 v96z - HEADINGS\n\n');
fprintf(fid, 'MASTER: %s\n\n', masterPath);
for i = 1:height(Headings)
    fprintf(fid, '%04d | line %05d | char %08d | level %d | %s\n', ...
        i, Headings.line(i), Headings.charpos(i), Headings.level(i), char(Headings.raw(i)));
end
fclose(fid);

%% Write Markdown report
failed = Tchecks(~Tchecks.pass, :);
if isempty(failed)
    diagnosis = 'MASTER_SECTION_MAP_DIAGNOSTIC_AFTER_FIX1_PASS';
else
    diagnosis = 'MASTER_SECTION_MAP_DIAGNOSTIC_AFTER_FIX1_REVIEW_REQUIRED';
end

fid = fopen(reportPath, 'w');
fprintf(fid, '# MASTER_SECTION_MAP_DIAGNOSTIC_AFTER_FIX1_v96z report\n\n');
fprintf(fid, '## Identifier\n\n`MASTER-SECTION-MAP-DIAGNOSTIC-AFTER-FIX1-001`\n\n');
fprintf(fid, '## Mode\n\n`READ_ONLY`\n\n');
fprintf(fid, '## Diagnosis\n\n`%s`\n\n', diagnosis);

fprintf(fid, '## Files\n\n');
fprintf(fid, '- MASTER: `%s`\n', masterPath);
fprintf(fid, '- Headings report: `%s`\n', headingsPath);
fprintf(fid, '- Checks CSV: `%s`\n\n', checksPath);

fprintf(fid, '## Key positions\n\n');
fprintf(fid, '| item | char position | evidence |\n|---|---:|---|\n');
fprintf(fid, '| Results and discussion | %.0f | `%s` |\n', posResults, localHeadingSummary(Headings, idxResultsNumbered));
fprintf(fid, '| Discussion | %.0f | `%s` |\n', posDisc, discSummary);
fprintf(fid, '| Limitations | %.0f | `%s` |\n', posLim, limSummary);
fprintf(fid, '| Conclusions | %.0f | `%s` |\n', posConc, concSummary);
fprintf(fid, '| References | %.0f | `%s` |\n\n', posRef, refSummary);

fprintf(fid, '## Internal key positions\n\n');
fprintf(fid, '| block | char position | count |\n|---|---:|---:|\n');
fprintf(fid, '| Discussion key | %.0f | %d |\n', posKeyDiscussion, nKeyDiscussion);
fprintf(fid, '| Limitations key | %.0f | %d |\n', posKeyLimitations, nKeyLimitations);
fprintf(fid, '| Conclusions key | %.0f | %d |\n\n', posKeyConclusions, nKeyConclusions);

fprintf(fid, '## Placeholder status\n\n');
fprintf(fid, '| placeholder | present | char position |\n|---|---:|---:|\n');
fprintf(fid, '| # 8. Limitations pending | %d | %s |\n', ~isempty(placeholderLimitations), mat2str(placeholderLimitations));
fprintf(fid, '| # 9. Conclusions pending | %d | %s |\n\n', ~isempty(placeholderConclusions), mat2str(placeholderConclusions));

fprintf(fid, '## Glued heading evidence\n\n');
fprintf(fid, '- Glued critical headings: `%s`\n', localJoinMatches(gluedCrit));
fprintf(fid, '- Glued headings anywhere: `%s`\n', localJoinMatches(gluedAny));
fprintf(fid, '- Residual `20#` prefix count: `%d`\n\n', n20hash);

fprintf(fid, '## Failed checks\n\n');
if isempty(failed)
    fprintf(fid, 'None.\n\n');
else
    fprintf(fid, '| id | check | evidence |\n|---|---|---|\n');
    for i = 1:height(failed)
        fprintf(fid, '| `%s` | %s | `%s` |\n', ...
            char(failed.id(i)), char(failed.check(i)), char(failed.evidence(i)));
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
function T = localAddCheck(T, id, check, pass, evidence)
    if isempty(evidence)
        evidence = '';
    end
    newRow = table(string(id), string(check), logical(pass), string(evidence), ...
        'VariableNames', {'id','check','pass','evidence'});
    T = [T; newRow];
end

function s = localJoinMatches(matches)
    if isempty(matches)
        s = '';
    else
        s = char(join(string(matches), ' | '));
    end
end

function s = localHeadingSummary(Headings, idx)
    if isempty(idx)
        s = 'NOT_DETECTED';
        return;
    end
    parts = strings(numel(idx),1);
    for k = 1:numel(idx)
        ii = idx(k);
        parts(k) = sprintf('line=%d char=%d level=%d raw=%s', ...
            Headings.line(ii), Headings.charpos(ii), Headings.level(ii), char(Headings.raw(ii)));
    end
    s = char(join(parts, ' || '));
end

function p = localFirstChar(Headings, idx)
    if isempty(idx)
        p = NaN;
    else
        p = Headings.charpos(idx(1));
    end
end

function lvl = localSingleLevel(Headings, idx)
    if numel(idx) == 1
        lvl = Headings.level(idx);
    else
        lvl = NaN;
    end
end

function p = localFirstMatch(txt, pattern)
    p0 = strfind(txt, pattern);
    if isempty(p0)
        p = NaN;
    else
        p = p0(1);
    end
end
