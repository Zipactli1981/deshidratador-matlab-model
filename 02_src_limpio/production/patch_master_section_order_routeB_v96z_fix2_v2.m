%% patch_master_section_order_routeB_v96z_fix2.m
% 9.6z-fix2-script
% RESTORE-PREFIX1-BACKUP-THEN-CONSERVATIVE-ORDER-FIX2-ROUTEB-001
% WRITE_WITH_BACKUP_AND_STOP_GUARDS
%
% Purpose:
%   Restore the MASTER manuscript from the pre-fix1 backup and reconstruct
%   the Route-B editorial architecture:
%
%     # 7. Results and discussion
%       ... existing 7.1--7.4 content ...
%       ## 7.5 Discussion
%     # 8. Limitations
%     # 9. Conclusions
%     # 10. Nomenclature
%     # 11. References
%     # 12. Supplementary material
%
% Safety policy:
%   - Creates a backup of the CURRENT MASTER before writing.
%   - Uses the PRE-FIX1 backup as source.
%   - Extracts developed blocks by internal keys, not by fragile heading level.
%   - Writes only if all required prewrite checks pass.
%   - Does NOT run GA.
%   - Does NOT run the drying model.
%
% Outputs:
%   - PATCH_MASTER_SECTION_ORDER_ROUTEB_v96z_fix2_report.md
%   - PATCH_MASTER_SECTION_ORDER_ROUTEB_v96z_fix2_Tchecks.csv
%   - MASTER_HEADINGS_DETECTED_v96z_routeB_fix2_after.txt

clear; clc;

fprintf('\n=== PATCH MASTER SECTION ORDER ROUTE-B v96z fix2 ===\n');

%% Paths
rootDir = 'C:\Users\PC\MATLAB Drive\modelo_deshidratador_GA_chile_red_controlado_v1_3_HYBRID_IRR_COMPARE_CONSOLIDADA';

masterPath = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'draft_sections', ...
    'MASTER_manuscript_v01.md');

preFix1BackupPath = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'draft_sections', ...
    'MASTER_manuscript_v01_BEFORE_SECTION_ORDER_PATCH_FIX1_v96z_20260703_161840.md');

reviewDir = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'review');

if ~exist(reviewDir, 'dir')
    mkdir(reviewDir);
end

ts = datestr(now, 'yyyymmdd_HHMMSS');
currentBackupPath = fullfile(rootDir, ...
    '06_manuscript', 'article_Q1', 'draft_sections', ...
    ['MASTER_manuscript_v01_BEFORE_FIX2_ROUTEB_v96z_' ts '.md']);

reportPath = fullfile(reviewDir, ...
    'PATCH_MASTER_SECTION_ORDER_ROUTEB_v96z_fix2_report.md');

checksPath = fullfile(reviewDir, ...
    'PATCH_MASTER_SECTION_ORDER_ROUTEB_v96z_fix2_Tchecks.csv');

headingsAfterPath = fullfile(reviewDir, ...
    'MASTER_HEADINGS_DETECTED_v96z_routeB_fix2_after.txt');

%% Check table helper
Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Tchecks = addCheck(Tchecks, 'FX2B-PRE-01', 'MASTER actual exists', ...
    exist(masterPath, 'file') == 2, masterPath);

Tchecks = addCheck(Tchecks, 'FX2B-PRE-02', 'Pre-fix1 backup exists', ...
    exist(preFix1BackupPath, 'file') == 2, preFix1BackupPath);

if any(~Tchecks.pass)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, currentBackupPath, preFix1BackupPath, ...
        'PATCH_MASTER_SECTION_ORDER_ROUTEB_FIX2_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_MISSING_REQUIRED_FILE', 'Required source file missing.');
end

%% Read files
currentTxtRaw = fileread(masterPath);
backupTxtRaw  = fileread(preFix1BackupPath);

currentTxt = normalizeNewlines(currentTxtRaw);
sourceTxt  = normalizeNewlines(backupTxtRaw);

Tchecks = addCheck(Tchecks, 'FX2B-PRE-03', 'MASTER actual readable', ...
    strlength(string(currentTxt)) > 0, sprintf('chars=%d', strlength(string(currentTxt))));

Tchecks = addCheck(Tchecks, 'FX2B-PRE-04', 'Pre-fix1 backup readable', ...
    strlength(string(sourceTxt)) > 0, sprintf('chars=%d', strlength(string(sourceTxt))));

%% Normalize glued headings globally in source text
% Conservative normalization: if a heading marker is preceded by any non-newline
% character, insert two newlines before the marker. This preserves the preceding
% character as its own text and prevents silent deletion of possible content.
sourceNorm = regexprep(sourceTxt, '([^\n])(#{1,6}\s+)', '$1\n\n$2');
sourceNorm = regexprep(sourceNorm, '\n{3,}', '\n\n');

%% Internal keys for developed blocks
keyDiscussion = 'The formal R1 optimization and the subsequent sensitivity and baseline analyses indicate';
keyLimitations = 'Several limitations must be considered when interpreting the optimization and baseline-comparison results';
keyConclusions = 'This study developed a controlled multiobjective optimization and post-processing workflow';

nKeyDiscussion = countOccurrences(sourceNorm, keyDiscussion);
nKeyLimitations = countOccurrences(sourceNorm, keyLimitations);
nKeyConclusions = countOccurrences(sourceNorm, keyConclusions);

Tchecks = addCheck(Tchecks, 'FX2B-PRE-05', 'Discussion key exists exactly once in source', ...
    nKeyDiscussion == 1, sprintf('count=%d', nKeyDiscussion));

Tchecks = addCheck(Tchecks, 'FX2B-PRE-06', 'Limitations key exists exactly once in source', ...
    nKeyLimitations == 1, sprintf('count=%d', nKeyLimitations));

Tchecks = addCheck(Tchecks, 'FX2B-PRE-07', 'Conclusions key exists exactly once in source', ...
    nKeyConclusions == 1, sprintf('count=%d', nKeyConclusions));

%% Parse headings after normalization
H = getHeadings(sourceNorm);

idxSec7  = findHeadingExact(H, '# 7. Results and discussion');
idxSec8  = findHeadingExact(H, '# 8. Limitations');
idxSec9  = findHeadingExact(H, '# 9. Conclusions');
idxSec10 = findHeadingExact(H, '# 10. Nomenclature');
idxSec11 = findHeadingExact(H, '# 11. References');
idxSec12 = findHeadingExact(H, '# 12. Supplementary material');

Tchecks = addCheck(Tchecks, 'FX2B-PRE-08', '# 7 Results and discussion exists in source', ...
    numel(idxSec7) == 1, headingSummary(H, idxSec7));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-09', '# 8 Limitations exists in source', ...
    numel(idxSec8) == 1, headingSummary(H, idxSec8));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-10', '# 9 Conclusions exists in source', ...
    numel(idxSec9) == 1, headingSummary(H, idxSec9));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-11', '# 10 Nomenclature exists in source', ...
    numel(idxSec10) == 1, headingSummary(H, idxSec10));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-12', '# 11 References exists in source after normalization', ...
    numel(idxSec11) == 1, headingSummary(H, idxSec11));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-13', '# 12 Supplementary material exists in source', ...
    numel(idxSec12) == 1, headingSummary(H, idxSec12));

%% Extract developed blocks by keys
[discussionBlockRaw, discussionEvidence] = extractBlockContainingKey(sourceNorm, keyDiscussion);
[limitationsBlockRaw, limitationsEvidence] = extractBlockContainingKey(sourceNorm, keyLimitations);
[conclusionsBlockRaw, conclusionsEvidence] = extractBlockContainingKey(sourceNorm, keyConclusions);

Tchecks = addCheck(Tchecks, 'FX2B-PRE-14', 'Discussion developed block extracted', ...
    strlength(string(discussionBlockRaw)) > 0, discussionEvidence);
Tchecks = addCheck(Tchecks, 'FX2B-PRE-15', 'Limitations developed block extracted', ...
    strlength(string(limitationsBlockRaw)) > 0, limitationsEvidence);
Tchecks = addCheck(Tchecks, 'FX2B-PRE-16', 'Conclusions developed block extracted', ...
    strlength(string(conclusionsBlockRaw)) > 0, conclusionsEvidence);

if any(~Tchecks.pass)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, currentBackupPath, preFix1BackupPath, ...
        'PATCH_MASTER_SECTION_ORDER_ROUTEB_FIX2_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_PRECHECK_FAILED', 'Prewrite checks failed before reconstruction.');
end

%% Clean extracted blocks: remove their heading line and status lines if any
% We will reassign canonical headings explicitly.
discussionBody = stripBlockHeading(discussionBlockRaw, {'Discussion'});
limitationsBody = stripBlockHeading(limitationsBlockRaw, {'Limitations'});
conclusionsBody = stripBlockHeading(conclusionsBlockRaw, {'Conclusions'});

% Remove old blocks from source, then rebuild canonical manuscript tail.
workTxt = sourceNorm;
workTxt = removeBlockContainingKey(workTxt, keyDiscussion);
workTxt = removeBlockContainingKey(workTxt, keyLimitations);
workTxt = removeBlockContainingKey(workTxt, keyConclusions);
workTxt = regexprep(workTxt, '\n{3,}', '\n\n');

%% Re-parse after removals
H2 = getHeadings(workTxt);
idx7  = findHeadingExact(H2, '# 7. Results and discussion');
idx8  = findHeadingExact(H2, '# 8. Limitations');
idx9  = findHeadingExact(H2, '# 9. Conclusions');
idx10 = findHeadingExact(H2, '# 10. Nomenclature');
idx11 = findHeadingExact(H2, '# 11. References');
idx12 = findHeadingExact(H2, '# 12. Supplementary material');

Tchecks = addCheck(Tchecks, 'FX2B-PRE-17', 'After extraction, canonical anchor headings remain unique', ...
    all([numel(idx7), numel(idx8), numel(idx9), numel(idx10), numel(idx11), numel(idx12)] == 1), ...
    sprintf('7=%d 8=%d 9=%d 10=%d 11=%d 12=%d', numel(idx7), numel(idx8), numel(idx9), numel(idx10), numel(idx11), numel(idx12)));

if any(~Tchecks.pass)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, currentBackupPath, preFix1BackupPath, ...
        'PATCH_MASTER_SECTION_ORDER_ROUTEB_FIX2_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_ANCHOR_CHECK_FAILED_AFTER_EXTRACTION', 'Required anchors were not unique after block extraction.');
end

%% Segment manuscript into canonical regions
p7  = H2.charpos(idx7);
p8  = H2.charpos(idx8);
p9  = H2.charpos(idx9);
p10 = H2.charpos(idx10);
p11 = H2.charpos(idx11);
p12 = H2.charpos(idx12);

orderAnchorsOK = p7 < p8 && p8 < p9 && p9 < p10 && p10 < p11 && p11 < p12;
Tchecks = addCheck(Tchecks, 'FX2B-PRE-18', 'Canonical anchors are in increasing order before reconstruction', ...
    orderAnchorsOK, sprintf('7=%d 8=%d 9=%d 10=%d 11=%d 12=%d', p7, p8, p9, p10, p11, p12));

if ~orderAnchorsOK
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, currentBackupPath, preFix1BackupPath, ...
        'PATCH_MASTER_SECTION_ORDER_ROUTEB_FIX2_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_ANCHOR_ORDER_INVALID', 'Canonical anchors are not ordered.');
end

prefixToBeforeSec8 = char(extractBefore(string(workTxt), p8));
sec8ToBeforeSec9   = char(extractBetween(string(workTxt), p8, p9-1));
sec9ToBeforeSec10  = char(extractBetween(string(workTxt), p9, p10-1));
sec10ToEnd         = char(extractAfter(string(workTxt), p10-1));

%% Remove placeholder bodies for #8 and #9
% Keep only the section headings; replace pending content with developed content.
sec8Heading = '# 8. Limitations';
sec9Heading = '# 9. Conclusions';

% Defensive: canonical segment should start with corresponding heading.
Tchecks = addCheck(Tchecks, 'FX2B-PRE-19', 'Section 8 segment starts with # 8. Limitations', ...
    startsWith(strtrim(sec8ToBeforeSec9), sec8Heading), firstLine(sec8ToBeforeSec9));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-20', 'Section 9 segment starts with # 9. Conclusions', ...
    startsWith(strtrim(sec9ToBeforeSec10), sec9Heading), firstLine(sec9ToBeforeSec10));

if any(~Tchecks.pass)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, currentBackupPath, preFix1BackupPath, ...
        'PATCH_MASTER_SECTION_ORDER_ROUTEB_FIX2_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_SEGMENT_CHECK_FAILED', 'Section 8 or 9 segment not recognized.');
end

%% Build Route-B manuscript
prefixToBeforeSec8 = ensureEndsWithBlankLine(prefixToBeforeSec8);

% Insert discussion as final subsection of #7, immediately before #8.
discussionSection = sprintf('## 7.5 Discussion\n\n%s\n\n', strtrim(discussionBody));
limitationsSection = sprintf('# 8. Limitations\n\n%s\n\n', strtrim(limitationsBody));
conclusionsSection = sprintf('# 9. Conclusions\n\n%s\n\n', strtrim(conclusionsBody));

newTxt = [prefixToBeforeSec8 discussionSection limitationsSection conclusionsSection sec10ToEnd];
newTxt = normalizeNewlines(newTxt);
newTxt = regexprep(newTxt, '\n{3,}', '\n\n');
newTxt = strtrim(newTxt);
newTxt = [newTxt newline];

%% Validate reconstructed text before writing
nNewDiscussionKey = countOccurrences(newTxt, keyDiscussion);
nNewLimitationsKey = countOccurrences(newTxt, keyLimitations);
nNewConclusionsKey = countOccurrences(newTxt, keyConclusions);

Tchecks = addCheck(Tchecks, 'FX2B-PRE-21', 'Reconstruction contains Discussion key once', ...
    nNewDiscussionKey == 1, sprintf('count=%d', nNewDiscussionKey));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-22', 'Reconstruction contains Limitations key once', ...
    nNewLimitationsKey == 1, sprintf('count=%d', nNewLimitationsKey));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-23', 'Reconstruction contains Conclusions key once', ...
    nNewConclusionsKey == 1, sprintf('count=%d', nNewConclusionsKey));

Hnew = getHeadings(newTxt);
idxNew7   = findHeadingExact(Hnew, '# 7. Results and discussion');
idxNewD   = findHeadingExact(Hnew, '## 7.5 Discussion');
idxNew8   = findHeadingExact(Hnew, '# 8. Limitations');
idxNew9   = findHeadingExact(Hnew, '# 9. Conclusions');
idxNew10  = findHeadingExact(Hnew, '# 10. Nomenclature');
idxNew11  = findHeadingExact(Hnew, '# 11. References');
idxNew12  = findHeadingExact(Hnew, '# 12. Supplementary material');

Tchecks = addCheck(Tchecks, 'FX2B-PRE-24', 'Reconstruction has ## 7.5 Discussion once', ...
    numel(idxNewD) == 1, headingSummary(Hnew, idxNewD));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-25', 'Reconstruction has # 8 Limitations once', ...
    numel(idxNew8) == 1, headingSummary(Hnew, idxNew8));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-26', 'Reconstruction has # 9 Conclusions once', ...
    numel(idxNew9) == 1, headingSummary(Hnew, idxNew9));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-27', 'Reconstruction has # 11 References once', ...
    numel(idxNew11) == 1, headingSummary(Hnew, idxNew11));

routeBOrderOK = false;
if all([numel(idxNew7), numel(idxNewD), numel(idxNew8), numel(idxNew9), numel(idxNew10), numel(idxNew11), numel(idxNew12)] == 1)
    routeBOrderOK = Hnew.charpos(idxNew7) < Hnew.charpos(idxNewD) && ...
        Hnew.charpos(idxNewD) < Hnew.charpos(idxNew8) && ...
        Hnew.charpos(idxNew8) < Hnew.charpos(idxNew9) && ...
        Hnew.charpos(idxNew9) < Hnew.charpos(idxNew10) && ...
        Hnew.charpos(idxNew10) < Hnew.charpos(idxNew11) && ...
        Hnew.charpos(idxNew11) < Hnew.charpos(idxNew12);
end

Tchecks = addCheck(Tchecks, 'FX2B-PRE-28', 'Route-B order valid in reconstruction', ...
    routeBOrderOK, routeBPositionEvidence(Hnew, idxNew7, idxNewD, idxNew8, idxNew9, idxNew10, idxNew11, idxNew12));

nGluedAny = numel(regexp(newTxt, '[^\n]#{1,6}\s+', 'match'));
n20hash = numel(regexp(newTxt, '20#{1,6}', 'match'));

Tchecks = addCheck(Tchecks, 'FX2B-PRE-29', 'Reconstruction has no glued headings', ...
    nGluedAny == 0, sprintf('glued_heading_count=%d', nGluedAny));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-30', 'Reconstruction has no 20# heading prefixes', ...
    n20hash == 0, sprintf('20#_prefix_count=%d', n20hash));

pendingLim = ~isempty(regexp(newTxt, '# 8\. Limitations\s+`STATUS:\s*PENDING`', 'once'));
pendingCon = ~isempty(regexp(newTxt, '# 9\. Conclusions\s+`STATUS:\s*PENDING`', 'once'));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-31', 'No pending placeholder remains in #8 or #9', ...
    ~(pendingLim || pendingCon), sprintf('pendingLimitations=%d pendingConclusions=%d', pendingLim, pendingCon));

%% Prohibited wording / claim checks
prohibitedGlobalOpt = ~isempty(regexpi(newTxt, 'global\s+optimum|global\s+optimality|globally\s+optimal', 'once'));
prohibitedPareto = ~isempty(regexpi(newTxt, 'global\s+Pareto\s+front|complete\s+Pareto[-\s]?front\s+characterization', 'once'));
statRobustClaim = ~isempty(regexpi(newTxt, 'statistical\s+robustness\s+(was|is|has been)\s+(demonstrated|proved|established)', 'once'));
finalCO2Claim = ~isempty(regexpi(newTxt, 'final\s+CO2\s+claim|definitive\s+CO2\s+claim', 'once'));
finalCostClaim = ~isempty(regexpi(newTxt, 'final\s+cost\s+claim|definitive\s+cost\s+claim', 'once'));

Tchecks = addCheck(Tchecks, 'FX2B-PRE-32', 'No prohibited global optimum wording in reconstruction', ...
    ~prohibitedGlobalOpt, sprintf('present=%d', prohibitedGlobalOpt));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-33', 'No prohibited global Pareto front wording in reconstruction', ...
    ~prohibitedPareto, sprintf('present=%d', prohibitedPareto));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-34', 'No unsupported statistical robustness claim in reconstruction', ...
    ~statRobustClaim, sprintf('present=%d', statRobustClaim));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-35', 'No final CO2 claim in reconstruction', ...
    ~finalCO2Claim, sprintf('present=%d', finalCO2Claim));
Tchecks = addCheck(Tchecks, 'FX2B-PRE-36', 'No final cost claim in reconstruction', ...
    ~finalCostClaim, sprintf('present=%d', finalCostClaim));

if any(~Tchecks.pass)
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, currentBackupPath, preFix1BackupPath, ...
        'PATCH_MASTER_SECTION_ORDER_ROUTEB_FIX2_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_RECONSTRUCTION_CHECK_FAILED', 'Reconstructed text failed prewrite validation.');
end

%% Write: backup current MASTER, then write reconstructed MASTER
try
    copyfile(masterPath, currentBackupPath);
    backupCreated = exist(currentBackupPath, 'file') == 2;
catch ME
    backupCreated = false;
    backupErr = ME.message;
end

if ~exist('backupErr','var')
    backupErr = currentBackupPath;
end

Tchecks = addCheck(Tchecks, 'FX2B-WRITE-01', 'Current MASTER backup created before write', ...
    backupCreated, backupErr);

if ~backupCreated
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, currentBackupPath, preFix1BackupPath, ...
        'PATCH_MASTER_SECTION_ORDER_ROUTEB_FIX2_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_BACKUP_CREATION_FAILED', 'Could not backup current MASTER.');
end

fid = fopen(masterPath, 'w');
if fid < 0
    Tchecks = addCheck(Tchecks, 'FX2B-WRITE-02', 'MASTER opened for writing', false, masterPath);
    writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, currentBackupPath, preFix1BackupPath, ...
        'PATCH_MASTER_SECTION_ORDER_ROUTEB_FIX2_REVIEW_REQUIRED', ...
        'STOP_WITH_NO_WRITE_OPEN_FAILED', 'Could not open MASTER for writing.');
end
fprintf(fid, '%s', newTxt);
fclose(fid);

Tchecks = addCheck(Tchecks, 'FX2B-WRITE-02', 'MASTER written with Route-B reconstruction', true, masterPath);

%% Postwrite validation
postTxt = normalizeNewlines(fileread(masterPath));
Hpost = getHeadings(postTxt);

idxPost7  = findHeadingExact(Hpost, '# 7. Results and discussion');
idxPostD  = findHeadingExact(Hpost, '## 7.5 Discussion');
idxPost8  = findHeadingExact(Hpost, '# 8. Limitations');
idxPost9  = findHeadingExact(Hpost, '# 9. Conclusions');
idxPost10 = findHeadingExact(Hpost, '# 10. Nomenclature');
idxPost11 = findHeadingExact(Hpost, '# 11. References');
idxPost12 = findHeadingExact(Hpost, '# 12. Supplementary material');

postRouteOK = false;
if all([numel(idxPost7), numel(idxPostD), numel(idxPost8), numel(idxPost9), numel(idxPost10), numel(idxPost11), numel(idxPost12)] == 1)
    postRouteOK = Hpost.charpos(idxPost7) < Hpost.charpos(idxPostD) && ...
        Hpost.charpos(idxPostD) < Hpost.charpos(idxPost8) && ...
        Hpost.charpos(idxPost8) < Hpost.charpos(idxPost9) && ...
        Hpost.charpos(idxPost9) < Hpost.charpos(idxPost10) && ...
        Hpost.charpos(idxPost10) < Hpost.charpos(idxPost11) && ...
        Hpost.charpos(idxPost11) < Hpost.charpos(idxPost12);
end

Tchecks = addCheck(Tchecks, 'FX2B-POST-01', 'MASTER updated', true, masterPath);
Tchecks = addCheck(Tchecks, 'FX2B-POST-02', 'Backup of current MASTER exists', exist(currentBackupPath, 'file') == 2, currentBackupPath);
Tchecks = addCheck(Tchecks, 'FX2B-POST-03', 'No glued headings remain', numel(regexp(postTxt, '[^\n]#{1,6}\s+', 'match')) == 0, sprintf('count=%d', numel(regexp(postTxt, '[^\n]#{1,6}\s+', 'match'))));
Tchecks = addCheck(Tchecks, 'FX2B-POST-04', 'No 20# heading prefixes remain', numel(regexp(postTxt, '20#{1,6}', 'match')) == 0, sprintf('count=%d', numel(regexp(postTxt, '20#{1,6}', 'match'))));
Tchecks = addCheck(Tchecks, 'FX2B-POST-05', 'Discussion key count equals one', countOccurrences(postTxt, keyDiscussion) == 1, sprintf('count=%d', countOccurrences(postTxt, keyDiscussion)));
Tchecks = addCheck(Tchecks, 'FX2B-POST-06', 'Limitations key count equals one', countOccurrences(postTxt, keyLimitations) == 1, sprintf('count=%d', countOccurrences(postTxt, keyLimitations)));
Tchecks = addCheck(Tchecks, 'FX2B-POST-07', 'Conclusions key count equals one', countOccurrences(postTxt, keyConclusions) == 1, sprintf('count=%d', countOccurrences(postTxt, keyConclusions)));
Tchecks = addCheck(Tchecks, 'FX2B-POST-08', '## 7.5 Discussion exists once', numel(idxPostD) == 1, headingSummary(Hpost, idxPostD));
Tchecks = addCheck(Tchecks, 'FX2B-POST-09', '# 8 Limitations exists once', numel(idxPost8) == 1, headingSummary(Hpost, idxPost8));
Tchecks = addCheck(Tchecks, 'FX2B-POST-10', '# 9 Conclusions exists once', numel(idxPost9) == 1, headingSummary(Hpost, idxPost9));
Tchecks = addCheck(Tchecks, 'FX2B-POST-11', '# 10 Nomenclature exists once', numel(idxPost10) == 1, headingSummary(Hpost, idxPost10));
Tchecks = addCheck(Tchecks, 'FX2B-POST-12', '# 11 References exists once', numel(idxPost11) == 1, headingSummary(Hpost, idxPost11));
Tchecks = addCheck(Tchecks, 'FX2B-POST-13', 'Route-B order valid after write', postRouteOK, routeBPositionEvidence(Hpost, idxPost7, idxPostD, idxPost8, idxPost9, idxPost10, idxPost11, idxPost12));
Tchecks = addCheck(Tchecks, 'FX2B-POST-14', 'No STATUS PENDING remains in #8 or #9', ...
    isempty(regexp(postTxt, '# 8\. Limitations\s+`STATUS:\s*PENDING`|# 9\. Conclusions\s+`STATUS:\s*PENDING`', 'once')), 'Route-B #8/#9 replacement');
Tchecks = addCheck(Tchecks, 'FX2B-POST-15', 'No prohibited global optimum wording', ~prohibitedGlobalOpt, 'No prohibited wording introduced');
Tchecks = addCheck(Tchecks, 'FX2B-POST-16', 'No prohibited global Pareto front wording', ~prohibitedPareto, 'No prohibited wording introduced');
Tchecks = addCheck(Tchecks, 'FX2B-POST-17', 'No unsupported statistical robustness claim', ~statRobustClaim, 'No overclaim introduced');
Tchecks = addCheck(Tchecks, 'FX2B-POST-18', 'No final CO2 claim', ~finalCO2Claim, 'No final CO2 claim introduced');
Tchecks = addCheck(Tchecks, 'FX2B-POST-19', 'No final cost claim', ~finalCostClaim, 'No final cost claim introduced');
Tchecks = addCheck(Tchecks, 'FX2B-POST-20', 'No GA executed', true, 'Text reconstruction only');
Tchecks = addCheck(Tchecks, 'FX2B-POST-21', 'No model executed', true, 'Text reconstruction only');

%% Write headings after report
writeHeadingsFile(headingsAfterPath, masterPath, Hpost);

%% Final report
if all(Tchecks.pass)
    diagnosis = 'PATCH_MASTER_SECTION_ORDER_ROUTEB_FIX2_PASS';
    decision = 'MASTER_UPDATED_WITH_ROUTEB_SECTION_ORDER';
else
    diagnosis = 'PATCH_MASTER_SECTION_ORDER_ROUTEB_FIX2_REVIEW_REQUIRED';
    decision = 'MASTER_UPDATED_BUT_POSTCHECKS_REQUIRE_INSPECTION';
end

writePatchReport(reportPath, Tchecks, diagnosis, decision, masterPath, currentBackupPath, preFix1BackupPath, headingsAfterPath);
writetable(Tchecks, checksPath);

failed = Tchecks(~Tchecks.pass, :);

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Decision:  %s\n', decision);
fprintf('Report:    %s\n', reportPath);
fprintf('Checks:    %s\n', checksPath);
fprintf('Headings:  %s\n', headingsAfterPath);
fprintf('Backup:    %s\n', currentBackupPath);

if ~isempty(failed)
    fprintf('\nFailed checks:\n');
    disp(failed(:, {'id','check','evidence'}));
end

fprintf('\nPATCH_MASTER_SECTION_ORDER_ROUTEB_FIX2_DONE\n');

%% Local functions
function txt = normalizeNewlines(txt)
    txt = strrep(txt, char([13 10]), newline);
    txt = strrep(txt, char(13), newline);
end

function T = addCheck(T, id, check, pass, evidence)
    T = [T; table(string(id), string(check), logical(pass), string(evidence), ...
        'VariableNames', {'id','check','pass','evidence'})];
end

function n = countOccurrences(txt, pat)
    n = numel(strfind(txt, pat));
end

function H = getHeadings(txt)
    txt = normalizeNewlines(txt);
    lines = splitlines(string(txt));
    nLines = numel(lines);
    lineStart = zeros(nLines,1);
    pos = 1;
    for i = 1:nLines
        lineStart(i) = pos;
        pos = pos + strlength(lines(i)) + 1;
    end

    rowLine = [];
    rowChar = [];
    rowLevel = [];
    rowRaw = strings(0,1);
    rowTitle = strings(0,1);

    for i = 1:nLines
        li = char(lines(i));
        tok = regexp(li, '^(#{1,6})\s+(.+?)\s*$', 'tokens', 'once');
        if ~isempty(tok)
            rowLine(end+1,1) = i; %#ok<AGROW>
            rowChar(end+1,1) = lineStart(i); %#ok<AGROW>
            rowLevel(end+1,1) = length(tok{1}); %#ok<AGROW>
            rowRaw(end+1,1) = string(li); %#ok<AGROW>
            rowTitle(end+1,1) = string(strtrim(tok{2})); %#ok<AGROW>
        end
    end

    H = table(rowLine, rowChar, rowLevel, rowRaw, rowTitle, ...
        'VariableNames', {'line','charpos','level','raw','title'});
end

function idx = findHeadingExact(H, rawOrTitle)
    q = string(strtrim(rawOrTitle));
    if startsWith(q, '#')
        idx = find(strcmp(strtrim(H.raw), q));
    else
        idx = find(strcmp(strtrim(H.title), q));
    end
end

function s = headingSummary(H, idx)
    if isempty(idx)
        s = "NOT_DETECTED";
        return;
    end
    parts = strings(numel(idx),1);
    for k = 1:numel(idx)
        ii = idx(k);
        parts(k) = sprintf('line=%d char=%d level=%d raw=%s', H.line(ii), H.charpos(ii), H.level(ii), H.raw(ii));
    end
    s = join(parts, ' || ');
end

function [block, evidence] = extractBlockContainingKey(txt, key)
    H = getHeadings(txt);
    keyPos = strfind(txt, key);
    if isempty(keyPos)
        block = '';
        evidence = 'key not found';
        return;
    end
    keyPos = keyPos(1);
    before = find(H.charpos < keyPos);
    if isempty(before)
        block = '';
        evidence = 'no heading before key';
        return;
    end
    startIdx = before(end);
    startPos = H.charpos(startIdx);
    after = find(H.charpos > startPos);
    if isempty(after)
        endPos = strlength(string(txt)) + 1;
    else
        endPos = H.charpos(after(1));
    end
    block = char(extractBetween(string(txt), startPos, endPos-1));
    evidence = sprintf('start_line=%d start_char=%d end_char=%d heading=%s', H.line(startIdx), startPos, endPos-1, H.raw(startIdx));
end

function txtOut = removeBlockContainingKey(txt, key)
    H = getHeadings(txt);
    keyPos = strfind(txt, key);
    if isempty(keyPos)
        txtOut = txt;
        return;
    end
    keyPos = keyPos(1);
    before = find(H.charpos < keyPos);
    if isempty(before)
        txtOut = txt;
        return;
    end
    startIdx = before(end);
    startPos = H.charpos(startIdx);
    after = find(H.charpos > startPos);
    if isempty(after)
        endPos = strlength(string(txt)) + 1;
    else
        endPos = H.charpos(after(1));
    end
    txtStr = string(txt);
    txtOut = char(extractBefore(txtStr, startPos) + extractAfter(txtStr, endPos-1));
    txtOut = char(txtOut);
end

function body = stripBlockHeading(block, expectedTitles)
    lines = splitlines(string(normalizeNewlines(block)));
    if isempty(lines)
        body = '';
        return;
    end

    % Remove first heading line if it is a Markdown heading.
    first = char(lines(1));
    if ~isempty(regexp(first, '^#{1,6}\s+', 'once'))
        lines(1) = [];
    end

    % Remove common status metadata lines immediately after heading.
    removeMask = false(numel(lines),1);
    for i = 1:min(numel(lines), 8)
        li = strtrim(lines(i));
        if li == "" || startsWith(li, "`STATUS:") || startsWith(li, "Source section:") || startsWith(li, "Source sections:") || startsWith(li, "Source tables:") || startsWith(li, "Approved internal verdict:")
            % Blank lines are only removed in the leading metadata zone.
            removeMask(i) = true;
        else
            break;
        end
    end
    lines(removeMask) = [];
    body = char(join(lines, newline));
    body = strtrim(body);
end

function s = ensureEndsWithBlankLine(s)
    s = char(s);
    s = regexprep(s, '\s+$', '');
    s = [s newline newline];
end

function s = firstLine(txt)
    lines = splitlines(string(txt));
    if isempty(lines)
        s = "EMPTY";
    else
        s = lines(1);
    end
end

function ev = routeBPositionEvidence(H, idx7, idxD, idx8, idx9, idx10, idx11, idx12)
    ev = sprintf('7=%s | D=%s | 8=%s | 9=%s | 10=%s | 11=%s | 12=%s', ...
        posStr(H, idx7), posStr(H, idxD), posStr(H, idx8), posStr(H, idx9), posStr(H, idx10), posStr(H, idx11), posStr(H, idx12));
end

function s = posStr(H, idx)
    if isempty(idx)
        s = 'NaN';
    else
        s = sprintf('%d', H.charpos(idx(1)));
    end
end

function writeHeadingsFile(path, masterPath, H)
    fid = fopen(path, 'w');
    fprintf(fid, 'MASTER headings detected after Route-B fix2\n\n');
    fprintf(fid, 'MASTER: %s\n\n', masterPath);
    for i = 1:height(H)
        fprintf(fid, '%04d | line %05d | char %08d | level %d | %s\n', ...
            i, H.line(i), H.charpos(i), H.level(i), H.raw(i));
    end
    fclose(fid);
end

function writePatchReport(reportPath, Tchecks, diagnosis, decision, masterPath, currentBackupPath, preFix1BackupPath, headingsAfterPath)
    failed = Tchecks(~Tchecks.pass, :);
    fid = fopen(reportPath, 'w');
    fprintf(fid, '# PATCH_MASTER_SECTION_ORDER_ROUTEB_v96z_fix2 report\n\n');
    fprintf(fid, '## Identifier\n\n');
    fprintf(fid, '`RESTORE-PREFIX1-BACKUP-THEN-CONSERVATIVE-ORDER-FIX2-ROUTEB-001`\n\n');
    fprintf(fid, '## Diagnosis\n\n`%s`\n\n', diagnosis);
    fprintf(fid, '## Decision\n\n`%s`\n\n', decision);
    fprintf(fid, '## Patch mode\n\n`WRITE_WITH_BACKUP_AND_STOP_GUARDS`\n\n');
    fprintf(fid, '## Route-B target architecture\n\n');
    fprintf(fid, '```text\n# 7. Results and discussion\n## 7.5 Discussion\n# 8. Limitations\n# 9. Conclusions\n# 10. Nomenclature\n# 11. References\n# 12. Supplementary material\n```\n\n');
    fprintf(fid, '## Files\n\n');
    fprintf(fid, '- MASTER: `%s`\n', masterPath);
    fprintf(fid, '- Current MASTER backup before fix2: `%s`\n', currentBackupPath);
    fprintf(fid, '- Pre-fix1 source backup: `%s`\n', preFix1BackupPath);
    fprintf(fid, '- Headings after: `%s`\n\n', headingsAfterPath);
    fprintf(fid, '## Failed checks\n\n');
    if isempty(failed)
        fprintf(fid, 'None.\n\n');
    else
        fprintf(fid, '| id | check | evidence |\n');
        fprintf(fid, '|---|---|---|\n');
        for i = 1:height(failed)
            fprintf(fid, '| `%s` | %s | `%s` |\n', failed.id(i), failed.check(i), failed.evidence(i));
        end
        fprintf(fid, '\n');
    end
    fprintf(fid, '## Checks\n\n');
    fprintf(fid, '| id | check | pass | evidence |\n');
    fprintf(fid, '|---|---|---:|---|\n');
    for i = 1:height(Tchecks)
        fprintf(fid, '| `%s` | %s | %d | `%s` |\n', Tchecks.id(i), Tchecks.check(i), Tchecks.pass(i), Tchecks.evidence(i));
    end
    fclose(fid);
end

function writeReportAndStop(Tchecks, reportPath, checksPath, headingsAfterPath, masterPath, currentBackupPath, preFix1BackupPath, diagnosis, decision, note)
    try
        H = getHeadings(normalizeNewlines(fileread(masterPath)));
        writeHeadingsFile(headingsAfterPath, masterPath, H);
    catch
        % ignore heading-report failure in early missing-file states
    end
    writePatchReport(reportPath, Tchecks, diagnosis, decision + " | " + note, masterPath, currentBackupPath, preFix1BackupPath, headingsAfterPath);
    writetable(Tchecks, checksPath);
    fprintf('\nDiagnosis: %s\n', diagnosis);
    fprintf('Decision:  %s\n', decision);
    fprintf('Note:      %s\n', note);
    fprintf('Report:    %s\n', reportPath);
    fprintf('Checks:    %s\n', checksPath);
    fprintf('\nPATCH_MASTER_SECTION_ORDER_ROUTEB_FIX2_STOPPED_WITH_NO_WRITE\n');
    error('%s: %s', decision, note);
end
