%% audit_master_preliminary_review_post_repair_v96z.m
% 9.6z-audit-e
% MASTER-PRELIMINARY-REVIEW-POST-REPAIR-AUDIT-v96z-001
% READ_ONLY
%
% Purpose:
%   Audit the MASTER after preliminary-review repairs.
%
% This audit verifies:
%   1. Route-B structure remains valid.
%   2. Duplicate modular skeleton headings in 3.1--3.5, 5.1--5.4, 6.1--6.4.
%   3. #5 Mathematical model is no longer a hollow bullet skeleton.
%   4. Abstract and Conclusions include the 31--45% hybrid-vs-gas-LPG auxiliary-energy reduction.
%   5. Limitations include explicit GA search-budget limitation: seed=61001, pop=24, gen=50, exitflag=0.
%   6. Repetition counts for key modular phrases.
%   7. Figure/table integration remains visible as next editorial layer.
%
% READ_ONLY: does not modify MASTER, does not run GA, does not run the drying model.

clear; clc;

fprintf('\n=== MASTER PRELIMINARY REVIEW POST-REPAIR AUDIT v96z ===\n');

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
    'MASTER_PRELIMINARY_REVIEW_POST_REPAIR_AUDIT_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_PRELIMINARY_REVIEW_POST_REPAIR_AUDIT_v96z_Tchecks.csv');

findingsPath = fullfile(reviewDir, ...
    'MASTER_PRELIMINARY_REVIEW_POST_REPAIR_AUDIT_v96z_findings.csv');

inventoryPath = fullfile(reviewDir, ...
    'MASTER_PRELIMINARY_REVIEW_POST_REPAIR_AUDIT_v96z_section_inventory.csv');

headingsPath = fullfile(reviewDir, ...
    'MASTER_HEADINGS_DETECTED_v96z_post_repair_audit.txt');

T = table(string.empty,string.empty,logical.empty,string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

Findings = table(string.empty,string.empty,string.empty,string.empty, ...
    'VariableNames', {'severity','location','finding','evidence'});

T = addCheck(T,'MPRA-001','MASTER exists',exist(masterPath,'file')==2,masterPath);

if exist(masterPath,'file') ~= 2
    writeAllAndFinish(T,Findings,reportPath,checksPath,findingsPath,inventoryPath,headingsPath,masterPath, ...
        'MASTER_PRELIMINARY_REVIEW_POST_REPAIR_AUDIT_REVIEW_REQUIRED', ...
        'MASTER_NOT_FOUND');
    error('MASTER_NOT_FOUND');
end

txt = normalizeNewlines(fileread(masterPath));
T = addCheck(T,'MPRA-002','MASTER readable',strlength(string(txt))>0,sprintf('chars=%d',strlength(string(txt))));

H = detectHeadings(txt);
writeHeadings(H, headingsPath, masterPath);

T = addCheck(T,'MPRA-003','Route-B order valid',routeOK(H),routeEvidence(H));

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
    if isempty(hidx(H, expectedMain(k)))
        missing(end+1,1) = expectedMain(k); %#ok<AGROW>
    end
end
T = addCheck(T,'MPRA-004','All main sections detected',isempty(missing),pick(isempty(missing),'all detected',strjoin(missing,' | ')));

Inventory = buildInventory(txt,H);
writetable(Inventory, inventoryPath);

% Duplicate modular skeleton scan.
[targetDupCount, targetDupEvidence] = duplicateTargetHeadingCount(H);
T = addCheck(T,'MPRA-010','No duplicate modular subsection headings in 3/5/6',targetDupCount==0, ...
    sprintf('duplicates=%d | %s',targetDupCount,targetDupEvidence));
if targetDupCount > 0
    Findings = addFinding(Findings,'major','Sections 3/5/6','Duplicate modular skeleton headings remain',targetDupEvidence);
end

% Section 5 model completeness.
model = sec(txt,H,'# 5. Mathematical model');
eqDelims = countLit(model,'$$');
bullets = countLit(model,[newline '- ']);
hasStateVector = contains(string(model),'x(t)') && contains(string(model),'T_a') && contains(string(model),'T_p') && contains(string(model),'MR') && contains(string(model),'T_s');
hasDecisionVector = contains(string(model),'m_dot') && contains(string(model),'T_min') && contains(string(model),'r_rec') && contains(string(model),'t_rec_ini');
hasAirEq = contains(string(model),'dT_a') || contains(string(model),'\frac{dT_a}{dt}');
hasProdEq = contains(string(model),'dT_p') || contains(string(model),'\frac{dT_p}{dt}');
hasMREq = contains(string(model),'dMR') || contains(string(model),'\frac{dMR}{dt}');
hasStructEq = contains(string(model),'dT_s') || contains(string(model),'\frac{dT_s}{dt}');
hasQaux = contains(string(model),'Q_aux') || contains(string(model),'Q_{aux}');
hasMRcriterion = contains(string(model),'MR <= 0.1') || contains(string(model),'MR \leq 0.1');

T = addCheck(T,'MPRA-020','#5 contains state vector',hasStateVector, ...
    sprintf('x(t)=%d | T_a=%d | T_p=%d | MR=%d | T_s=%d',contains(string(model),'x(t)'),contains(string(model),'T_a'),contains(string(model),'T_p'),contains(string(model),'MR'),contains(string(model),'T_s')));

T = addCheck(T,'MPRA-021','#5 contains optimization decision-variable traceability',hasDecisionVector, ...
    sprintf('m_dot=%d | T_min=%d | r_rec=%d | t_rec_ini=%d',contains(string(model),'m_dot'),contains(string(model),'T_min'),contains(string(model),'r_rec'),contains(string(model),'t_rec_ini')));

T = addCheck(T,'MPRA-022','#5 contains four ODE components',hasAirEq && hasProdEq && hasMREq && hasStructEq, ...
    sprintf('air=%d | product=%d | MR=%d | structure=%d',hasAirEq,hasProdEq,hasMREq,hasStructEq));

T = addCheck(T,'MPRA-023','#5 links model outputs to Q_aux and MR criterion',hasQaux && hasMRcriterion, ...
    sprintf('Q_aux=%d | MRcriterion=%d',hasQaux,hasMRcriterion));

T = addCheck(T,'MPRA-024','#5 no longer appears as bullet-only skeleton',eqDelims>=6 && bullets<=12, ...
    sprintf('equationDelimiters=%d | bullets=%d',eqDelims,bullets));

if ~(hasStateVector && hasDecisionVector && hasAirEq && hasProdEq && hasMREq && hasStructEq && hasQaux)
    Findings = addFinding(Findings,'major','#5 Mathematical model','Model section still lacks enough verifiable mathematical structure', ...
        sprintf('state=%d decision=%d ODEs=%d%d%d%d Q_aux=%d',hasStateVector,hasDecisionVector,hasAirEq,hasProdEq,hasMREq,hasStructEq,hasQaux));
end

% Abstract and conclusions.
abstract = sec(txt,H,'# 1. Abstract');
conclusions = sec(txt,H,'# 9. Conclusions');
absHas31 = contains(string(abstract),'31--45%') || contains(string(abstract),'31–45%') || contains(string(abstract),'31-45%');
concHas31 = contains(string(conclusions),'31--45%') || contains(string(conclusions),'31–45%') || contains(string(conclusions),'31-45%');
absHasBaseline = contains(string(abstract),'gas-LPG baseline');
concHasBaseline = contains(string(conclusions),'gas-LPG baseline');

T = addCheck(T,'MPRA-030','Abstract includes 31--45% hybrid-vs-gas-LPG reduction',absHas31 && absHasBaseline, ...
    sprintf('31to45=%d | gas-LPG baseline=%d',absHas31,absHasBaseline));

T = addCheck(T,'MPRA-031','Conclusions include 31--45% hybrid-vs-gas-LPG reduction',concHas31 && concHasBaseline, ...
    sprintf('31to45=%d | gas-LPG baseline=%d',concHas31,concHasBaseline));

if ~(absHas31 && concHas31)
    Findings = addFinding(Findings,'major','Abstract/Conclusions','31--45% result is still not consistently elevated', ...
        sprintf('abstract=%d conclusions=%d',absHas31,concHas31));
end

% Limitations.
limitations = sec(txt,H,'# 8. Limitations');
hasSeed = contains(string(limitations),'seed = 61001') || contains(string(limitations),'seed=61001');
hasPop = contains(string(limitations),'population size of 24') || contains(string(limitations),'population = 24') || contains(string(limitations),'pop=24');
hasGen = contains(string(limitations),'50 generations') || contains(string(limitations),'generations = 50') || contains(string(limitations),'gen=50');
hasExit = contains(string(limitations),'exitflag = 0') || contains(string(limitations),'exitflag=0');
hasFiniteSearch = contains(lower(string(limitations)),'finite computational search') || contains(lower(string(limitations)),'search-budget limitation') || contains(lower(string(limitations)),'generation limit');

T = addCheck(T,'MPRA-040','Limitations explicitly state GA search-budget limitation', ...
    hasSeed && hasPop && hasGen && hasExit && hasFiniteSearch, ...
    sprintf('seed=%d | pop=%d | gen=%d | exitflag=%d | finiteSearch=%d',hasSeed,hasPop,hasGen,hasExit,hasFiniteSearch));

if ~(hasSeed && hasPop && hasGen && hasExit)
    Findings = addFinding(Findings,'major','#8 Limitations','GA search-budget limitation remains incomplete', ...
        sprintf('seed=%d pop=%d gen=%d exitflag=%d',hasSeed,hasPop,hasGen,hasExit));
end

% Repetition scan.
phrases = [
    "computed nondominated set"
    "R1_solution_7"
    "energy-conservative feasible candidate"
    "historical reference"
    "single seed"
    "additional independent seed replications"
    "not newly optimized"
];

counts = zeros(numel(phrases),1);
for k = 1:numel(phrases)
    counts(k) = countLit(txt, char(phrases(k)));
end

repetitionEvidence = join(compose('%s=%d', phrases, counts), ' | ');
T = addCheck(T,'MPRA-050','Repetition scan recorded for modular-assembly cleanup',true,repetitionEvidence);

computedNondomCount = counts(phrases=="computed nondominated set");
T = addCheck(T,'MPRA-051','Computed nondominated set repetition below severe threshold',computedNondomCount <= 10, ...
    sprintf('count=%d threshold<=10',computedNondomCount));

if computedNondomCount > 10
    Findings = addFinding(Findings,'moderate','whole manuscript','Phrase repetition remains visible: computed nondominated set', ...
        sprintf('count=%d',computedNondomCount));
end

% Figure/table integration scan.
figRefs = countRegex(txt,'\bFigure\s+[0-9]+') + countRegex(txt,'\bFig\.\s*[0-9]+');
tableRefs = countRegex(txt,'\bTable\s+[0-9]+');
mdTables = countRegex(txt,'^\|.*\|');

T = addCheck(T,'MPRA-060','Figure references present for review copy',figRefs > 0, sprintf('figureRefs=%d',figRefs));
T = addCheck(T,'MPRA-061','Table references or markdown tables present for review copy',tableRefs > 0 || mdTables > 0, sprintf('tableRefs=%d | markdownTableLines=%d',tableRefs,mdTables));

if figRefs == 0
    Findings = addFinding(Findings,'major','figures','No integrated figure references detected', ...
        'At minimum: system schematic, optimization workflow, selected candidates/trade-off plot.');
end
if tableRefs == 0 && mdTables == 0
    Findings = addFinding(Findings,'major','tables','No integrated tables detected', ...
        'At minimum: GA configuration, selected candidates, hybrid vs gas-LPG comparison.');
end

% Citation/reference state.
citationHits = countCitationLikeMarkers(txt);
T = addCheck(T,'MPRA-070','Citation markers present',citationHits > 0, sprintf('citation_like_hits=%d',citationHits));
if citationHits == 0
    Findings = addFinding(Findings,'major','citations','No in-text citations detected', ...
        'Expected for final pre-submission, but may remain open for preliminary review.');
end

% Safety checks.
globalParetoCount = countLit(txt,'global Pareto front') + countLit(txt,'global Pareto-front') + countLit(txt,'complete global Pareto front');
T = addCheck(T,'MPRA-080','No audit-trigger global Pareto wording',globalParetoCount==0,sprintf('count=%d',globalParetoCount));

globalOptClaim = hasUnsupportedGlobalOptimumClaim(txt);
T = addCheck(T,'MPRA-081','No unsupported global optimum claim',~globalOptClaim,sprintf('present=%d',globalOptClaim));

T = addCheck(T,'MPRA-090','No GA executed',true,'READ_ONLY audit');
T = addCheck(T,'MPRA-091','No drying model executed',true,'READ_ONLY audit');
T = addCheck(T,'MPRA-092','MASTER not modified',true,'READ_ONLY audit');

% Summary status.
majorFindings = sum(Findings.severity=="major");
moderateFindings = sum(Findings.severity=="moderate");

hardFailIds = [
    "MPRA-001"
    "MPRA-002"
    "MPRA-003"
    "MPRA-004"
    "MPRA-010"
    "MPRA-020"
    "MPRA-021"
    "MPRA-022"
    "MPRA-023"
    "MPRA-024"
    "MPRA-030"
    "MPRA-031"
    "MPRA-040"
    "MPRA-080"
    "MPRA-081"
];

hardFailed = T(~T.pass & ismember(T.id, hardFailIds), :);

if isempty(hardFailed)
    if majorFindings == 0
        diagnosis = 'MASTER_PRELIMINARY_REVIEW_POST_REPAIR_AUDIT_PASS';
        decision = 'READY_FOR_REDUNDANCY_AND_FIGTAB_LAYER';
    else
        diagnosis = 'MASTER_PRELIMINARY_REVIEW_POST_REPAIR_AUDIT_REVIEW_REQUIRED';
        decision = 'MAJOR_EDITORIAL_ITEMS_REMAIN_BEFORE_STYLE_LAYER';
    end
else
    diagnosis = 'MASTER_PRELIMINARY_REVIEW_POST_REPAIR_AUDIT_REVIEW_REQUIRED';
    decision = 'POST_REPAIR_HARD_CHECKS_FAILED';
end

T = addCheck(T,'MPRA-999','Audit classification summary',isempty(hardFailed) && majorFindings==0, ...
    sprintf('hardFailed=%d | majorFindings=%d | moderateFindings=%d',height(hardFailed),majorFindings,moderateFindings));

writeAllAndFinish(T,Findings,reportPath,checksPath,findingsPath,inventoryPath,headingsPath,masterPath,diagnosis,decision);

fprintf('\nDiagnosis: %s\n', diagnosis);
fprintf('Decision:  %s\n', decision);
fprintf('Report:    %s\n', reportPath);
fprintf('Checks:    %s\n', checksPath);
fprintf('Findings:  %s\n', findingsPath);
fprintf('Inventory: %s\n', inventoryPath);
fprintf('Headings:  %s\n', headingsPath);

failed = T(~T.pass,:);
if ~isempty(failed)
    fprintf('\nFailed checks:\n');
    disp(failed(:,{'id','check','evidence'}));
end

fprintf('\nMASTER_PRELIMINARY_REVIEW_POST_REPAIR_AUDIT_DONE\n');

%% Local functions
function T = addCheck(T,id,check,pass,evidence)
    if isempty(pass), passScalar=false; else, passScalar=all(logical(pass(:))); end
    if ischar(evidence), e=string(evidence);
    elseif isstring(evidence), e=strjoin(evidence(:).',' | ');
    else, e=string(evidence); end
    T=[T; table(string(id),string(check),logical(passScalar),string(e), ...
        'VariableNames',{'id','check','pass','evidence'})];
end

function F = addFinding(F,severity,location,finding,evidence)
    F=[F; table(string(severity),string(location),string(finding),string(evidence), ...
        'VariableNames',{'severity','location','finding','evidence'})];
end

function t = normalizeNewlines(t)
    t=strrep(t,char([13 10]),newline);
    t=strrep(t,char(13),newline);
end

function s = pick(c,a,b)
    if c, s=a; else, s=b; end
end

function n = countLit(t,p)
    if isstring(t), t=char(t); end
    if isstring(p), p=char(p); end
    n=numel(strfind(t,p));
end

function n = countRegex(t,pat)
    m=regexp(char(string(t)),pat,'match','lineanchors');
    n=numel(m);
end

function n = countCitationLikeMarkers(t)
    s=char(string(t));
    pats={'\[[0-9]+\]','\([A-Z][A-Za-z\-]+,\s*[0-9]{4}\)','\[[A-Z]+-[A-Z0-9\-]+\]'};
    n=0;
    for k=1:numel(pats)
        n=n+numel(regexp(s,pats{k},'match'));
    end
end

function H = detectHeadings(t)
    t=normalizeNewlines(t);
    L=splitlines(string(t));
    n=numel(L);
    starts=zeros(n,1);
    pos=1;
    for i=1:n
        starts(i)=pos;
        pos=pos+strlength(L(i))+1;
    end
    ln=[]; cp=[]; lv=[];
    raw=strings(0,1); title=strings(0,1);
    for i=1:n
        li=char(L(i));
        tok=regexp(li,'^(#{1,6})\s+(.+?)\s*$','tokens','once');
        if ~isempty(tok)
            ln(end+1,1)=i; %#ok<AGROW>
            cp(end+1,1)=starts(i); %#ok<AGROW>
            lv(end+1,1)=numel(tok{1}); %#ok<AGROW>
            raw(end+1,1)=string(li); %#ok<AGROW>
            title(end+1,1)=string(strtrim(tok{2})); %#ok<AGROW>
        end
    end
    H=table(ln,cp,lv,raw,title,'VariableNames',{'line','charpos','level','raw','title'});
end

function ix = hidx(H,r)
    ix=find(strcmp(strtrim(H.raw),strtrim(string(r))));
end

function p = fchar(H,ix)
    if isempty(ix), p=NaN; else, p=H.charpos(ix(1)); end
end

function ok = routeOK(H)
    pos=[fchar(H,hidx(H,'# 7. Results and discussion')), ...
         fchar(H,hidx(H,'## 7.5 Discussion')), ...
         fchar(H,hidx(H,'# 8. Limitations')), ...
         fchar(H,hidx(H,'# 9. Conclusions')), ...
         fchar(H,hidx(H,'# 10. Nomenclature')), ...
         fchar(H,hidx(H,'# 11. References')), ...
         fchar(H,hidx(H,'# 12. Supplementary material'))];
    ok=all(~isnan(pos)) && all(diff(pos)>0);
end

function ev = routeEvidence(H)
    pos=[fchar(H,hidx(H,'# 7. Results and discussion')), ...
         fchar(H,hidx(H,'## 7.5 Discussion')), ...
         fchar(H,hidx(H,'# 8. Limitations')), ...
         fchar(H,hidx(H,'# 9. Conclusions')), ...
         fchar(H,hidx(H,'# 10. Nomenclature')), ...
         fchar(H,hidx(H,'# 11. References')), ...
         fchar(H,hidx(H,'# 12. Supplementary material'))];
    ev=sprintf('7=%g | D=%g | 8=%g | 9=%g | 10=%g | 11=%g | 12=%g',pos);
end

function sg = sec(t,H,r)
    ix=hidx(H,r);
    if isempty(ix), sg=''; return; end
    i=ix(1);
    st=H.charpos(i);
    en=strlength(string(t))+1;
    for j=i+1:height(H)
        if H.level(j)<=H.level(i)
            en=H.charpos(j);
            break;
        end
    end
    sg=char(extractBetween(string(t),st,en-1));
end

function [dupCount, ev] = duplicateTargetHeadingCount(H)
    keys=strings(height(H),1);
    target=false(height(H),1);
    labels=strings(0,1);
    for i=1:height(H)
        tok=regexp(char(H.raw(i)),'^##\s+(3\.[1-5]|5\.[1-4]|6\.[1-4])\b','tokens','once');
        if ~isempty(tok)
            keys(i)=string(tok{1});
            target(i)=true;
        end
    end
    dupCount=0;
    uk=unique(keys(target));
    for k=1:numel(uk)
        if strlength(uk(k))==0, continue; end
        ids=find(target & keys==uk(k));
        if numel(ids)>1
            dupCount=dupCount+(numel(ids)-1);
            labels(end+1,1)=sprintf('%s occurs %d times',uk(k),numel(ids)); %#ok<AGROW>
        end
    end
    if isempty(labels), ev='none'; else, ev=char(strjoin(labels,' | ')); end
end

function Inv = buildInventory(t,H)
    n=height(H);
    wc=zeros(n,1);
    cc=zeros(n,1);
    status=strings(n,1);
    for i=1:n
        st=H.charpos(i);
        en=strlength(string(t))+1;
        for j=i+1:n
            if H.level(j)<=H.level(i), en=H.charpos(j); break; end
        end
        sg=char(extractBetween(string(t),st,en-1));
        cc(i)=strlength(string(sg));
        words=regexp(sg,'\S+','match');
        wc(i)=numel(words);
        tok=regexp(sg,'`STATUS:\s*([^`]+)`','tokens','once');
        if isempty(tok), status(i)=""; else, status(i)=string(strtrim(tok{1})); end
    end
    Inv=table(H.line,H.charpos,H.level,H.raw,status,wc,cc, ...
        'VariableNames',{'line','charpos','level','heading','status','word_count','char_count'});
end

function present = hasUnsupportedGlobalOptimumClaim(txt)
    s=lower(string(normalizeNewlines(txt)));
    lines=splitlines(s);
    present=false;
    prohibited=["global optimum","globally optimal","global optimality"];
    protective=["do not","does not","no claim","not claim","not as","not be interpreted","should not","avoid","prohibited","restriction","instead of","proof of","not proof","no prohibited","not used as a claim"];
    for i=1:numel(lines)
        li=strtrim(lines(i));
        if ~any(contains(li,prohibited)), continue; end
        if ~any(contains(li,protective)), present=true; return; end
    end
end

function writeHeadings(H,p,master)
    fid=fopen(p,'w');
    fprintf(fid,'MASTER HEADINGS DETECTED - POST REPAIR AUDIT\n\nMASTER: %s\n\n',master);
    for i=1:height(H)
        fprintf(fid,'%04d | line %05d | char %08d | level %d | %s\n',i,H.line(i),H.charpos(i),H.level(i),H.raw(i));
    end
    fclose(fid);
end

function writeAllAndFinish(T,F,report,checks,findings,inventory,headings,master,diagnosis,decision)
    writetable(T,checks);
    writetable(F,findings);
    fid=fopen(report,'w');
    fprintf(fid,'# MASTER_PRELIMINARY_REVIEW_POST_REPAIR_AUDIT_v96z report\n\n');
    fprintf(fid,'## Identifier\n\n`MASTER-PRELIMINARY-REVIEW-POST-REPAIR-AUDIT-v96z-001`\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Audit mode\n\n`READ_ONLY`\n\n');
    fprintf(fid,'## Files\n\n- MASTER: `%s`\n- Checks: `%s`\n- Findings: `%s`\n- Inventory: `%s`\n- Headings: `%s`\n\n',master,checks,findings,inventory,headings);
    failed=T(~T.pass,:);
    fprintf(fid,'## Failed checks\n\n');
    if isempty(failed)
        fprintf(fid,'None.\n\n');
    else
        fprintf(fid,'| id | check | evidence |\n|---|---|---|\n');
        for i=1:height(failed)
            fprintf(fid,'| `%s` | %s | `%s` |\n',failed.id(i),failed.check(i),failed.evidence(i));
        end
        fprintf(fid,'\n');
    end
    fprintf(fid,'## Findings\n\n');
    if isempty(F)
        fprintf(fid,'None.\n\n');
    else
        fprintf(fid,'| severity | location | finding | evidence |\n|---|---|---|---|\n');
        for i=1:height(F)
            fprintf(fid,'| %s | %s | %s | `%s` |\n',F.severity(i),F.location(i),F.finding(i),F.evidence(i));
        end
        fprintf(fid,'\n');
    end
    fprintf(fid,'## Checks\n\n| id | check | pass | evidence |\n|---|---|---:|---|\n');
    for i=1:height(T)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n',T.id(i),T.check(i),T.pass(i),T.evidence(i));
    end
    fclose(fid);
end
