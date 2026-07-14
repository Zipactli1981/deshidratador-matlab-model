%% audit_master_manuscript_consistency_routeB_v96z_v2.m
% 9.6z-audit-c-routeB
% MASTER-MANUSCRIPT-CONSISTENCY-AUDIT-ROUTEB-001
% READ_ONLY
%
% Route-B target:
%   # 7. Results and discussion
%   ## 7.5 Discussion
%   # 8. Limitations
%   # 9. Conclusions
%   # 10. Nomenclature
%   # 11. References
%   # 12. Supplementary material
%
% This script reads MASTER only. It does not modify MASTER, run GA, or run the model.

clear; clc;

fprintf('\n=== MASTER MANUSCRIPT CONSISTENCY AUDIT ROUTE-B v96z ===\n');

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
    'MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_ROUTEB_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_ROUTEB_v96z_Tchecks.csv');

headingsPath = fullfile(reviewDir, ...
    'MASTER_HEADINGS_DETECTED_v96z_audit_routeB.txt');

Tchecks = table(string.empty, string.empty, logical.empty, string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Tchecks = addCheck(Tchecks, 'MACCB-001', 'MASTER exists', ...
    exist(masterPath, 'file') == 2, masterPath);

if exist(masterPath, 'file') ~= 2
    writetable(Tchecks, checksPath);
    error('MASTER not found: %s', masterPath);
end

txt = fileread(masterPath);
txt = normalizeNewlines(txt);
txtStr = string(txt);

Tchecks = addCheck(Tchecks, 'MACCB-002', 'MASTER read successfully', ...
    strlength(txtStr) > 0, sprintf('chars=%d', strlength(txtStr)));

Headings = detectCleanHeadings(txt);

Tchecks = addCheck(Tchecks, 'MACCB-003', 'Clean Markdown headings detected', ...
    height(Headings) > 0, sprintf('clean_headings=%d', height(Headings)));

writeHeadingsReport(Headings, headingsPath, masterPath);

idx7  = findHeadingExact(Headings, '# 7. Results and discussion');
idxD  = findHeadingExact(Headings, '## 7.5 Discussion');
idx8  = findHeadingExact(Headings, '# 8. Limitations');
idx9  = findHeadingExact(Headings, '# 9. Conclusions');
idx10 = findHeadingExact(Headings, '# 10. Nomenclature');
idx11 = findHeadingExact(Headings, '# 11. References');
idx12 = findHeadingExact(Headings, '# 12. Supplementary material');

Tchecks = addCheck(Tchecks, 'MACCB-004', '# 7 Results and discussion exists once', numel(idx7)==1, headingSummary(Headings,idx7));
Tchecks = addCheck(Tchecks, 'MACCB-005', '## 7.5 Discussion exists once', numel(idxD)==1, headingSummary(Headings,idxD));
Tchecks = addCheck(Tchecks, 'MACCB-006', '# 8 Limitations exists once', numel(idx8)==1, headingSummary(Headings,idx8));
Tchecks = addCheck(Tchecks, 'MACCB-007', '# 9 Conclusions exists once', numel(idx9)==1, headingSummary(Headings,idx9));
Tchecks = addCheck(Tchecks, 'MACCB-008', '# 10 Nomenclature exists once', numel(idx10)==1, headingSummary(Headings,idx10));
Tchecks = addCheck(Tchecks, 'MACCB-009', '# 11 References exists once', numel(idx11)==1, headingSummary(Headings,idx11));
Tchecks = addCheck(Tchecks, 'MACCB-010', '# 12 Supplementary material exists once', numel(idx12)==1, headingSummary(Headings,idx12));

pos7  = firstChar(Headings, idx7);
posD  = firstChar(Headings, idxD);
pos8  = firstChar(Headings, idx8);
pos9  = firstChar(Headings, idx9);
pos10 = firstChar(Headings, idx10);
pos11 = firstChar(Headings, idx11);
pos12 = firstChar(Headings, idx12);

routeBOrderValid = all(~isnan([pos7 posD pos8 pos9 pos10 pos11 pos12])) && ...
    pos7 < posD && posD < pos8 && pos8 < pos9 && pos9 < pos10 && pos10 < pos11 && pos11 < pos12;

Tchecks = addCheck(Tchecks, 'MACCB-011', 'Route-B manuscript order valid', ...
    routeBOrderValid, sprintf('7=%g | D=%g | 8=%g | 9=%g | 10=%g | 11=%g | 12=%g', pos7,posD,pos8,pos9,pos10,pos11,pos12));

idxFreeD = findHeadingExact(Headings, '## Discussion');
idxFreeL = findHeadingExact(Headings, '## Limitations');
idxFreeC = findHeadingExact(Headings, '## Conclusions');

Tchecks = addCheck(Tchecks, 'MACCB-012', 'No free-floating ## Discussion heading remains', isempty(idxFreeD), headingSummary(Headings,idxFreeD));
Tchecks = addCheck(Tchecks, 'MACCB-013', 'No free-floating ## Limitations heading remains', isempty(idxFreeL), headingSummary(Headings,idxFreeL));
Tchecks = addCheck(Tchecks, 'MACCB-014', 'No free-floating ## Conclusions heading remains', isempty(idxFreeC), headingSummary(Headings,idxFreeC));

keyDiscussion = 'The formal R1 optimization and the subsequent sensitivity and baseline analyses indicate';
keyLimitations = 'Several limitations must be considered when interpreting the optimization and baseline-comparison results';
keyConclusions = 'This study developed a controlled multiobjective optimization and post-processing workflow';

nKeyD = countLiteral(txt, keyDiscussion);
nKeyL = countLiteral(txt, keyLimitations);
nKeyC = countLiteral(txt, keyConclusions);

Tchecks = addCheck(Tchecks, 'MACCB-015', 'Discussion internal key count equals one', nKeyD==1, sprintf('count=%d', nKeyD));
Tchecks = addCheck(Tchecks, 'MACCB-016', 'Limitations internal key count equals one', nKeyL==1, sprintf('count=%d', nKeyL));
Tchecks = addCheck(Tchecks, 'MACCB-017', 'Conclusions internal key count equals one', nKeyC==1, sprintf('count=%d', nKeyC));

posKeyD = firstLiteralPos(txt, keyDiscussion);
posKeyL = firstLiteralPos(txt, keyLimitations);
posKeyC = firstLiteralPos(txt, keyConclusions);

keyOrderValid = all(~isnan([posKeyD posKeyL posKeyC])) && posKeyD < posKeyL && posKeyL < posKeyC;

Tchecks = addCheck(Tchecks, 'MACCB-018', ...
    'Developed block internal key order is Discussion -> Limitations -> Conclusions', ...
    keyOrderValid, sprintf('DiscussionKey=%g | LimitationsKey=%g | ConclusionsKey=%g', posKeyD,posKeyL,posKeyC));

Tchecks = addCheck(Tchecks, 'MACCB-019', 'Developed blocks occur before References', ...
    all(~isnan([posKeyD posKeyL posKeyC pos11])) && posKeyD < pos11 && posKeyL < pos11 && posKeyC < pos11, ...
    sprintf('DiscussionKey=%g | LimitationsKey=%g | ConclusionsKey=%g | References=%g', posKeyD,posKeyL,posKeyC,pos11));

seg8 = extractBetweenAnchors(txt, pos8, pos9);
seg9 = extractBetweenAnchors(txt, pos9, pos10);

pending8 = contains(string(seg8), '`STATUS: PENDING`');
pending9 = contains(string(seg9), '`STATUS: PENDING`');

Tchecks = addCheck(Tchecks, 'MACCB-020', 'No pending placeholder remains in # 8 Limitations', ~pending8, sprintf('pending=%d', pending8));
Tchecks = addCheck(Tchecks, 'MACCB-021', 'No pending placeholder remains in # 9 Conclusions', ~pending9, sprintf('pending=%d', pending9));

gluedCritical = regexp(txt, '[^\n#]#{1,6}\s+(Discussion|Limitations|Conclusions|References|Nomenclature|Supplementary material)', 'match');
gluedAnyLikely = regexp(txt, '[^\n#]#{1,6}\s+[A-Za-z0-9]', 'match');
n20hash = numel(regexp(txt, '20#{1,6}', 'match'));

Tchecks = addCheck(Tchecks, 'MACCB-022', 'No glued critical headings', isempty(gluedCritical), joinOrNone(gluedCritical));
Tchecks = addCheck(Tchecks, 'MACCB-023', 'No likely glued headings anywhere', isempty(gluedAnyLikely), joinOrNone(gluedAnyLikely));
Tchecks = addCheck(Tchecks, 'MACCB-024', 'No residual 20# heading prefixes', n20hash==0, sprintf('20#_prefix_count=%d', n20hash));

globalOptClaim = hasUnsupportedGlobalOptimumClaim(txt);
globalParetoClaim = hasUnsupportedGlobalParetoClaim(txt);
statRobustClaim = hasUnsupportedStatisticalRobustnessClaim(txt);

Tchecks = addCheck(Tchecks, 'MACCB-025', 'No prohibited global optimum/global optimality claim', ~globalOptClaim, sprintf('present=%d', globalOptClaim));
Tchecks = addCheck(Tchecks, 'MACCB-026', 'No prohibited global Pareto front claim', ~globalParetoClaim, sprintf('present=%d', globalParetoClaim));
Tchecks = addCheck(Tchecks, 'MACCB-027', 'No unsupported statistical robustness claim', ~statRobustClaim, sprintf('present=%d', statRobustClaim));

Tchecks = addCheck(Tchecks, 'MACCB-028', 'Uses computed nondominated set wording', contains(txtStr,'computed nondominated set'), sprintf('count=%d', countLiteral(txt,'computed nondominated set')));
Tchecks = addCheck(Tchecks, 'MACCB-029', 'H2 retained as historical reference', contains(txtStr,'historical reference'), sprintf('count=%d', countLiteral(txt,'historical reference')));
Tchecks = addCheck(Tchecks, 'MACCB-030', 'R1_solution_7 retained as energy-saving candidate', contains(txtStr,'R1_solution_7'), sprintf('count=%d', countLiteral(txt,'R1_solution_7')));
Tchecks = addCheck(Tchecks, 'MACCB-031', '2-SAH retained as sensitivity representation', contains(txtStr,'2-SAH') && contains(lower(txtStr),'sensitivity'), sprintf('2SAH_count=%d sensitivity_count=%d', countLiteral(txt,'2-SAH'), countLiteral(lower(txt),'sensitivity')));
Tchecks = addCheck(Tchecks, 'MACCB-032', 'Solar-only exclusion retained', contains(lower(txtStr),'solar-only') && contains(lower(txtStr),'excluded'), sprintf('solar_only_count=%d excluded_count=%d', countLiteral(lower(txt),'solar-only'), countLiteral(lower(txt),'excluded')));
Tchecks = addCheck(Tchecks, 'MACCB-033', 'Cost/CO2 caveat retained', contains(txtStr,'PROVISIONAL_FOR_CODE_VALIDATION') && contains(lower(txtStr),'co2'), sprintf('provisional_count=%d', countLiteral(txt,'PROVISIONAL_FOR_CODE_VALIDATION')));

finalCO2Claim = hasFinalCO2Claim(txt);
finalCostClaim = hasFinalCostClaim(txt);

Tchecks = addCheck(Tchecks, 'MACCB-034', 'No final CO2 claim', ~finalCO2Claim, sprintf('present=%d', finalCO2Claim));
Tchecks = addCheck(Tchecks, 'MACCB-035', 'No final cost claim', ~finalCostClaim, sprintf('present=%d', finalCostClaim));

requiredPhrases = [
    "R1_solution_7 was identified as the lowest-auxiliary-energy feasible solution"
    "R1_solution_3 represented a more balanced feasible candidate"
    "R1_solution_9 illustrated the opposite extreme of the trade-off"
    "hybrid operation reduced the auxiliary energy demand relative to the gas-LPG-only case"
    "Methodological implications"
];

for k = 1:numel(requiredPhrases)
    phrase = char(requiredPhrases(k));
    Tchecks = addCheck(Tchecks, sprintf('MACCB-%03d', 35+k), ...
        sprintf('Required Section 7 phrase retained: %s', phrase), ...
        contains(txtStr, phrase), sprintf('count=%d', countLiteral(txt, phrase)));
end

Tchecks = addCheck(Tchecks, 'MACCB-041', 'No GA executed by this audit', true, 'READ_ONLY text audit');
Tchecks = addCheck(Tchecks, 'MACCB-042', 'No drying model executed by this audit', true, 'READ_ONLY text audit');
Tchecks = addCheck(Tchecks, 'MACCB-043', 'MASTER was not modified by this audit', true, 'READ_ONLY no write to MASTER');

failed = Tchecks(~Tchecks.pass, :);

if isempty(failed)
    diagnosis = 'MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_ROUTEB_PASS';
    decision = 'MASTER_READY_FOR_NEXT_MANUSCRIPT_AUDIT_OR_EDITING_STEP';
else
    diagnosis = 'MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_ROUTEB_REVIEW_REQUIRED';
    decision = 'INSPECT_FAILED_CHECKS';
end

writetable(Tchecks, checksPath);

fid = fopen(reportPath, 'w');

fprintf(fid, '# MASTER_MANUSCRIPT_CONSISTENCY_AUDIT_ROUTEB_v96z report\n\n');
fprintf(fid, '## Identifier\n\n`MASTER-MANUSCRIPT-CONSISTENCY-AUDIT-ROUTEB-001`\n\n');
fprintf(fid, '## Mode\n\n`READ_ONLY`\n\n');
fprintf(fid, '## Diagnosis\n\n`%s`\n\n', diagnosis);
fprintf(fid, '## Decision\n\n`%s`\n\n', decision);

fprintf(fid, '## Route-B architecture audited\n\n');
fprintf(fid, '```text\n# 7. Results and discussion\n## 7.5 Discussion\n# 8. Limitations\n# 9. Conclusions\n# 10. Nomenclature\n# 11. References\n# 12. Supplementary material\n```\n\n');

fprintf(fid, '## Files\n\n');
fprintf(fid, '- MASTER: `%s`\n', masterPath);
fprintf(fid, '- Checks: `%s`\n', checksPath);
fprintf(fid, '- Headings: `%s`\n\n', headingsPath);

fprintf(fid, '## Key positions\n\n');
fprintf(fid, '| item | char position | evidence |\n|---|---:|---|\n');
fprintf(fid, '| # 7 Results and discussion | %.0f | `%s` |\n', pos7, headingSummary(Headings,idx7));
fprintf(fid, '| ## 7.5 Discussion | %.0f | `%s` |\n', posD, headingSummary(Headings,idxD));
fprintf(fid, '| # 8 Limitations | %.0f | `%s` |\n', pos8, headingSummary(Headings,idx8));
fprintf(fid, '| # 9 Conclusions | %.0f | `%s` |\n', pos9, headingSummary(Headings,idx9));
fprintf(fid, '| # 10 Nomenclature | %.0f | `%s` |\n', pos10, headingSummary(Headings,idx10));
fprintf(fid, '| # 11 References | %.0f | `%s` |\n', pos11, headingSummary(Headings,idx11));
fprintf(fid, '| # 12 Supplementary material | %.0f | `%s` |\n\n', pos12, headingSummary(Headings,idx12));

fprintf(fid, '## Failed checks\n\n');
if isempty(failed)
    fprintf(fid, 'None.\n\n');
else
    fprintf(fid, '| id | check | evidence |\n|---|---|---|\n');
    for i = 1:height(failed)
        fprintf(fid, '| `%s` | %s | `%s` |\n', failed.id(i), failed.check(i), failed.evidence(i));
    end
    fprintf(fid, '\n');
end

fprintf(fid, '## Checks\n\n');
fprintf(fid, '| id | check | pass | evidence |\n|---|---|---:|---|\n');
for i = 1:height(Tchecks)
    fprintf(fid, '| `%s` | %s | %d | `%s` |\n', Tchecks.id(i), Tchecks.check(i), Tchecks.pass(i), Tchecks.evidence(i));
end

fclose(fid);

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Decision:  %s\n', decision);
fprintf('Report:    %s\n', reportPath);
fprintf('Checks:    %s\n', checksPath);
fprintf('Headings:  %s\n', headingsPath);

if ~isempty(failed)
    fprintf('\nFailed checks:\n');
    disp(failed(:, {'id','check','evidence'}));
end

fprintf('\nMASTER_MANUSCRIPT_CONSISTENCY_AUDIT_ROUTEB_DONE\n');

%% Local functions

function T = addCheck(T,id,check,pass,evidence)
    T = [T; table(string(id), string(check), logical(pass), string(evidence), ...
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

function p = firstLiteralPos(txt, phrase)
    pos = strfind(txt, phrase);
    if isempty(pos), p = NaN; else, p = pos(1); end
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
    if isempty(idx), p = NaN; else, p = Headings.charpos(idx(1)); end
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

function out = joinOrNone(c)
    if isempty(c), out = "NONE"; else, out = join(string(c), ' | '); end
end

function segment = extractBetweenAnchors(txt, startPos, endPos)
    if isnan(startPos) || isnan(endPos) || startPos >= endPos
        segment = '';
        return;
    end
    segment = char(extractBetween(string(txt), startPos, endPos-1));
end

function writeHeadingsReport(Headings, outPath, masterPath)
    fid = fopen(outPath, 'w');
    fprintf(fid, 'MASTER HEADINGS DETECTED - ROUTE-B AUDIT\n\n');
    fprintf(fid, 'MASTER: %s\n\n', masterPath);
    for i = 1:height(Headings)
        fprintf(fid, '%04d | line %05d | char %08d | level %d | %s\n', ...
            i, Headings.line(i), Headings.charpos(i), Headings.level(i), Headings.raw(i));
    end
    fclose(fid);
end

function present = hasUnsupportedGlobalOptimumClaim(txt)
    % Line-level detector. It only fails affirmative claims.
    % It ignores restrictions, cautions, audit labels, and "do not claim" text.
    s = lower(string(normalizeNewlines(txt)));
    lines = splitlines(s);
    present = false;

    prohibited = ["global optimum", "globally optimal", "global optimality"];

    protectiveSignals = [
        "do not"
        "does not"
        "no claim"
        "not claim"
        "not as"
        "not be interpreted"
        "should not"
        "avoid"
        "prohibited"
        "restriction"
        "instead of"
        "proof of"
        "not proof"
        "no prohibited"
    ];

    for i = 1:numel(lines)
        li = strtrim(lines(i));
        if strlength(li) == 0
            continue;
        end

        hasProhibited = false;
        for k = 1:numel(prohibited)
            if contains(li, prohibited(k))
                hasProhibited = true;
            end
        end

        if ~hasProhibited
            continue;
        end

        protected = false;
        for k = 1:numel(protectiveSignals)
            if contains(li, protectiveSignals(k))
                protected = true;
            end
        end

        if ~protected
            present = true;
            return;
        end
    end
end

function present = hasUnsupportedGlobalParetoClaim(txt)
    % Line-level detector. It only fails affirmative claims.
    % It ignores restrictions, cautions, audit labels, and replacement instructions.
    s = lower(string(normalizeNewlines(txt)));
    lines = splitlines(s);
    present = false;

    prohibited = ["global pareto front", "complete pareto front", "complete pareto-front characterization"];

    protectiveSignals = [
        "do not"
        "does not"
        "no claim"
        "not claim"
        "not as"
        "not be interpreted"
        "should not"
        "avoid"
        "prohibited"
        "restriction"
        "instead of"
        "use computed nondominated set"
        "no prohibited"
    ];

    for i = 1:numel(lines)
        li = strtrim(lines(i));
        if strlength(li) == 0
            continue;
        end

        hasProhibited = false;
        for k = 1:numel(prohibited)
            if contains(li, prohibited(k))
                hasProhibited = true;
            end
        end

        if ~hasProhibited
            continue;
        end

        protected = false;
        for k = 1:numel(protectiveSignals)
            if contains(li, protectiveSignals(k))
                protected = true;
            end
        end

        if ~protected
            present = true;
            return;
        end
    end
end

function present = hasUnsupportedStatisticalRobustnessClaim(txt)
    s = lower(string(txt));
    protective = [
        "does not establish statistical robustness"
        "does not claim statistical robustness"
        "no claim of statistical robustness"
        "additional independent seed replications would be required"
        "not as proof of statistical robustness"
    ];
    for i = 1:numel(protective)
        s = replace(s, protective(i), "");
    end
    present = contains(s,"statistically robust") || ...
        contains(s,"statistical robustness was demonstrated") || ...
        contains(s,"robust across independent seeds") || ...
        contains(s,"robustness across independent seeds was demonstrated");
end

function present = hasFinalCO2Claim(txt)
    s = lower(string(txt));
    protective = [
        "no final co2 claim"
        "no final co2 claims"
        "final cost or co2 claims require"
        "final economic or co2 claims should remain conditional"
        "before making publication-grade cost or co2 claims"
        "not treated as final manuscript-grade emission factors"
        "until those factors are finalized"
    ];
    for i = 1:numel(protective)
        s = replace(s, protective(i), "");
    end
    present = contains(s,"final co2 claim") || contains(s,"final co2 claims") || ...
        contains(s,"definitive co2 reduction") || contains(s,"definitive emission reduction");
end

function present = hasFinalCostClaim(txt)
    s = lower(string(txt));
    protective = [
        "no final cost claim"
        "no final cost claims"
        "final cost or co2 claims require"
        "final economic or co2 claims should remain conditional"
        "before making publication-grade cost or co2 claims"
        "until those factors are finalized"
    ];
    for i = 1:numel(protective)
        s = replace(s, protective(i), "");
    end
    present = contains(s,"final cost claim") || contains(s,"final cost claims") || ...
        contains(s,"definitive cost reduction") || contains(s,"definitive economic benefit");
end
