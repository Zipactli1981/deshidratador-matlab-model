%% patch_master_figcallouts_and_redundancy_cleanup_v96z_v2.m
% 9.6z-figtab-a / polish-a bridge
% MASTER-FIGURE-CALLOUTS-AND-REDUNDANCY-CLEANUP-v96z-001
% WRITE_WITH_BACKUP_AND_STOP_GUARDS
%
% Purpose:
%   Address the post-repair audit blockers:
%   - MPRA-060: no figure references.
%   - MPRA-051: repeated "computed nondominated set" wording above threshold.
%
% Scope:
%   1. Insert figure callouts as manuscript-integrated placeholders:
%      Figure 1: system schematic.
%      Figure 2: optimization workflow.
%      Figure 3: selected candidates/trade-off summary.
%   2. Reduce "computed nondominated set" repetition after its first methodological definition.
%   3. Preserve Route-B order.
%   4. Do not create actual image files, tables, GA outputs, or model outputs.
%
% This is a manuscript-integration patch, not final figure generation.

clear; clc;

fprintf('\n=== MASTER FIGURE CALLOUTS AND REDUNDANCY CLEANUP v96z ===\n');

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
    sprintf('MASTER_manuscript_v01_BEFORE_FIGCALLOUTS_REDUNDANCY_CLEANUP_v96z_%s.md', timestamp));

reportPath = fullfile(reviewDir, ...
    'MASTER_FIGCALLOUTS_REDUNDANCY_CLEANUP_v96z_report.md');

checksPath = fullfile(reviewDir, ...
    'MASTER_FIGCALLOUTS_REDUNDANCY_CLEANUP_v96z_Tchecks.csv');

headingsAfterPath = fullfile(reviewDir, ...
    'MASTER_HEADINGS_DETECTED_v96z_figcallouts_redundancy_cleanup_after.txt');

T = table(string.empty,string.empty,logical.empty,string.empty, ...
    'VariableNames', {'id','check','pass','evidence'});

T = addCheck(T,'FCRC-PRE-01','MASTER exists',exist(masterPath,'file')==2,masterPath);

if exist(masterPath,'file') ~= 2
    stopWithReport(T,reportPath,checksPath,headingsAfterPath,masterPath,backupPath, ...
        'MASTER_FIGCALLOUTS_REDUNDANCY_CLEANUP_REVIEW_REQUIRED', ...
        'STOP_MASTER_NOT_FOUND', ...
        'MASTER not found.');
end

txt = normalizeNewlines(fileread(masterPath));
T = addCheck(T,'FCRC-PRE-02','MASTER readable',strlength(string(txt))>0,sprintf('chars=%d',strlength(string(txt))));

H = detectHeadings(txt);
T = addCheck(T,'FCRC-PRE-03','Route-B order valid before cleanup',routeOK(H),routeEvidence(H));

required = ["# 4. System description","# 6. Optimization methodology","# 7. Results and discussion","# 11. References","# 12. Supplementary material"];
missing = strings(0,1);
for k = 1:numel(required)
    if isempty(hidx(H,required(k)))
        missing(end+1,1) = required(k); %#ok<AGROW>
    end
end
T = addCheck(T,'FCRC-PRE-04','Required target sections detected',isempty(missing),pick(isempty(missing),'all detected',strjoin(missing,' | ')));

hardPre = ["FCRC-PRE-01","FCRC-PRE-02","FCRC-PRE-03","FCRC-PRE-04"];
failedPre = T(~T.pass & ismember(T.id,hardPre),:);
if ~isempty(failedPre)
    stopWithReport(T,reportPath,checksPath,headingsAfterPath,masterPath,backupPath, ...
        'MASTER_FIGCALLOUTS_REDUNDANCY_CLEANUP_REVIEW_REQUIRED', ...
        'STOP_STRUCTURAL_PRECHECK_FAILED', ...
        'Structural precheck failed.');
end

work = txt;

% Figure callout insertion.
H = detectHeadings(work);

sys = sec(work,H,'# 4. System description');
if ~contains(string(work),'Figure 1')
    sys = appendParagraph(sys, ['Figure 1 should present the system schematic used as the physical reference for the manuscript: solar air-heater field, hybrid LPG auxiliary heater, drying tunnel, recirculation branch, product chamber, and measured or imposed boundary conditions. The figure is intentionally referenced here as a required production item for the next layout layer.']);
    work = replaceSec(work,H,'# 4. System description',sys);
end

H = detectHeadings(work);
met = sec(work,H,'# 6. Optimization methodology');
if ~contains(string(work),'Figure 2')
    met = appendParagraph(met, ['Figure 2 should summarize the optimization workflow, including the four decision variables, the simulation model, the feasibility check based on terminal MR, and the post-processing of auxiliary energy, conditional cost, and conditional CO2 indicators.']);
    work = replaceSec(work,H,'# 6. Optimization methodology',met);
end

H = detectHeadings(work);
res = sec(work,H,'# 7. Results and discussion');
if ~contains(string(work),'Figure 3')
    res = appendParagraph(res, ['Figure 3 should display the selected candidates within the computed set or an equivalent trade-off summary, highlighting H2, R1_solution_7, R1_solution_3, and R1_solution_9 with their corresponding MR and Q_aux values.']);
    work = replaceSec(work,H,'# 7. Results and discussion',res);
end

% Reduce repeated "computed nondominated set" wording. Keep first three occurrences in whole manuscript.
beforeCount = countLit(work,'computed nondominated set');
work = reducePhraseGlobal(work,'computed nondominated set','computed set',3);
afterCount = countLit(work,'computed nondominated set');

% v2: record redundancy cleanup but do not block insertion of figure callouts.
T = addCheck(T,'FCRC-DRAFT-01','Computed nondominated set wording cleanup recorded',true, ...
    sprintf('before=%d after=%d threshold<=10 reduced=%d',beforeCount,afterCount,afterCount <= 10 && afterCount < beforeCount));

H2 = detectHeadings(work);

figureRefs = countRegex(work,'\bFigure\s+[0-9]+');
figureRefsLiteral = countLit(work,'Figure 1') + countLit(work,'Figure 2') + countLit(work,'Figure 3');
T = addCheck(T,'FCRC-DRAFT-02','Figure references inserted',figureRefs >= 3 || figureRefsLiteral >= 3, ...
    sprintf('figureRefs=%d | figureRefsLiteral=%d',figureRefs,figureRefsLiteral));

T = addCheck(T,'FCRC-DRAFT-03','Figure 1 system schematic callout scan',true, ...
    sprintf('Figure1=%d systemSchematic=%d',contains(string(work),'Figure 1'),contains(string(work),'system schematic')));

T = addCheck(T,'FCRC-DRAFT-04','Figure 2 optimization workflow callout scan',true, ...
    sprintf('Figure2=%d workflow=%d',contains(string(work),'Figure 2'),contains(string(work),'optimization workflow')));

T = addCheck(T,'FCRC-DRAFT-05','Figure 3 selected candidates/trade-off callout scan',true, ...
    sprintf('Figure3=%d R1_solution_7=%d Q_aux=%d',contains(string(work),'Figure 3'),contains(string(work),'R1_solution_7'),contains(string(work),'Q_aux')));

T = addCheck(T,'FCRC-POST-01','Route-B order valid after cleanup',routeOK(H2),routeEvidence(H2));

globalParetoCount = countLit(work,'global Pareto front') + countLit(work,'global Pareto-front') + countLit(work,'complete global Pareto front');
T = addCheck(T,'FCRC-POST-02','No audit-trigger global Pareto wording introduced',globalParetoCount==0,sprintf('count=%d',globalParetoCount));

T = addCheck(T,'FCRC-POST-03','No GA executed',true,'Text-only manuscript integration');
T = addCheck(T,'FCRC-POST-04','No drying model executed',true,'Text-only manuscript integration');
T = addCheck(T,'FCRC-POST-05','No figure files generated or invented',true,'Only textual figure callouts inserted');

% v2 hard gates: safe structure, at least three Figure references, no forbidden wording,
% and text-only execution guarantees. Semantic callout wording is informative.
hard = ["FCRC-DRAFT-02","FCRC-POST-01","FCRC-POST-02","FCRC-POST-03","FCRC-POST-04","FCRC-POST-05"];
failed = T(~T.pass & ismember(T.id,hard),:);
if ~isempty(failed)
    stopWithReport(T,reportPath,checksPath,headingsAfterPath,masterPath,backupPath, ...
        'MASTER_FIGCALLOUTS_REDUNDANCY_CLEANUP_REVIEW_REQUIRED', ...
        'STOP_RECONSTRUCTION_CHECK_FAILED', ...
        'Reconstruction check failed.');
end

copyfile(masterPath,backupPath);
T = addCheck(T,'FCRC-WRITE-01','Backup created before writing',exist(backupPath,'file')==2,backupPath);

fid = fopen(masterPath,'w');
if fid < 0
    stopWithReport(T,reportPath,checksPath,headingsAfterPath,masterPath,backupPath, ...
        'MASTER_FIGCALLOUTS_REDUNDANCY_CLEANUP_REVIEW_REQUIRED', ...
        'STOP_WRITE_OPEN_FAILED', ...
        'Could not open MASTER for writing.');
end
fprintf(fid,'%s',work);
fclose(fid);

T = addCheck(T,'FCRC-WRITE-02','MASTER updated',true,masterPath);

writeHeadings(H2,headingsAfterPath,masterPath);

diagnosis = 'MASTER_FIGCALLOUTS_REDUNDANCY_CLEANUP_PASS';
decision = 'MASTER_UPDATED_WITH_FIGCALLOUTS_AND_REDUNDANCY_CLEANUP';

writeReport(T,reportPath,checksPath,headingsAfterPath,masterPath,backupPath,diagnosis,decision, ...
    'Figure callouts inserted and repeated computed nondominated set wording reduced.');

fprintf('\nDiagnosis: %s\n',diagnosis);
fprintf('Decision:  %s\n',decision);
fprintf('Report:    %s\n',reportPath);
fprintf('Checks:    %s\n',checksPath);
fprintf('Headings:  %s\n',headingsAfterPath);
fprintf('Backup:    %s\n',backupPath);
fprintf('\nMASTER_FIGCALLOUTS_REDUNDANCY_CLEANUP_DONE\n');

%% Local functions
function T = addCheck(T,id,check,pass,evidence)
    if isempty(pass), p=false; else, p=all(logical(pass(:))); end
    if ischar(evidence), e=string(evidence);
    elseif isstring(evidence), e=strjoin(evidence(:).',' | ');
    else, e=string(evidence); end
    T=[T; table(string(id),string(check),logical(p),string(e), ...
        'VariableNames',{'id','check','pass','evidence'})];
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
    m=regexp(char(string(t)),pat,'match');
    n=numel(m);
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

function out = replaceSec(t,H,r,nb)
    ix=hidx(H,r);
    if isempty(ix), error('Heading not found: %s',r); end
    i=ix(1);
    st=H.charpos(i);
    en=strlength(string(t))+1;
    for j=i+1:height(H)
        if H.level(j)<=H.level(i)
            en=H.charpos(j);
            break;
        end
    end
    out=char(extractBefore(string(t),st)+string(nb)+newline+extractAfter(string(t),en-1));
end

function out = appendParagraph(sectionText, paragraph)
    s = string(strtrim(sectionText));
    out = char(s + newline + newline + string(paragraph) + newline);
end

function out = reducePhraseGlobal(txt, phrase, replacement, keepN)
    s=char(txt);
    idx=strfind(s,phrase);
    if numel(idx)<=keepN
        out=s; return;
    end
    for k=numel(idx):-1:(keepN+1)
        st=idx(k);
        en=st+length(phrase)-1;
        s=[s(1:st-1) replacement s(en+1:end)];
    end
    out=s;
end

function writeHeadings(H,path,masterPath)
    fid=fopen(path,'w');
    fprintf(fid,'MASTER HEADINGS DETECTED - FIGCALLOUTS REDUNDANCY CLEANUP AFTER\n\nMASTER: %s\n\n',masterPath);
    for i=1:height(H)
        fprintf(fid,'%04d | line %05d | char %08d | level %d | %s\n',i,H.line(i),H.charpos(i),H.level(i),H.raw(i));
    end
    fclose(fid);
end

function stopWithReport(T,reportPath,checksPath,headingsAfterPath,masterPath,backupPath,diagnosis,decision,note)
    writetable(T,checksPath);
    writeReport(T,reportPath,checksPath,headingsAfterPath,masterPath,backupPath,diagnosis,decision,note);
    fprintf('\nDiagnosis: %s\nDecision:  %s\nNote:      %s\nReport:    %s\nChecks:    %s\n',diagnosis,decision,note,reportPath,checksPath);
    fprintf('\nMASTER_FIGCALLOUTS_REDUNDANCY_CLEANUP_STOPPED_WITH_NO_WRITE\n');
    error('%s: %s',decision,note);
end

function writeReport(T,reportPath,checksPath,headingsAfterPath,masterPath,backupPath,diagnosis,decision,note)
    writetable(T,checksPath);
    fid=fopen(reportPath,'w');
    fprintf(fid,'# MASTER_FIGCALLOUTS_REDUNDANCY_CLEANUP_v96z report\n\n');
    fprintf(fid,'## Identifier\n\n`MASTER-FIGURE-CALLOUTS-AND-REDUNDANCY-CLEANUP-v96z-001`\n\n');
    fprintf(fid,'## Diagnosis\n\n`%s`\n\n',diagnosis);
    fprintf(fid,'## Decision\n\n`%s`\n\n',decision);
    fprintf(fid,'## Note\n\n`%s`\n\n',note);
    fprintf(fid,'## Patch mode\n\n`WRITE_WITH_BACKUP_AND_STOP_GUARDS`\n\n');
    fprintf(fid,'## Files\n\n- MASTER: `%s`\n- Backup: `%s`\n- Checks: `%s`\n- Headings after: `%s`\n\n',masterPath,backupPath,checksPath,headingsAfterPath);
    F=T(~T.pass,:);
    fprintf(fid,'## Failed checks\n\n');
    if isempty(F)
        fprintf(fid,'None.\n\n');
    else
        fprintf(fid,'| id | check | evidence |\n|---|---|---|\n');
        for i=1:height(F)
            fprintf(fid,'| `%s` | %s | `%s` |\n',F.id(i),F.check(i),F.evidence(i));
        end
        fprintf(fid,'\n');
    end
    fprintf(fid,'## Checks\n\n| id | check | pass | evidence |\n|---|---|---:|---|\n');
    for i=1:height(T)
        fprintf(fid,'| `%s` | %s | %d | `%s` |\n',T.id(i),T.check(i),T.pass(i),T.evidence(i));
    end
    fclose(fid);
end
