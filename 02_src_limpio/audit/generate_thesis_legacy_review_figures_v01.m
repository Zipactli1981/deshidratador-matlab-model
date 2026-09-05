function generate_thesis_legacy_review_figures_v01(outputDir)
% Generate review-only figures from persisted deterministic campaign tables.
    tablesDir = fullfile(outputDir, 'tables');
    figuresDir = fullfile(outputDir, 'figures');
    T = readtable(fullfile(tablesDir, 'THESIS_LEGACY_CURRENT_RESULTS.csv'), 'TextType', 'string');
    S = readtable(fullfile(tablesDir, 'THESIS_LEGACY_STATUS_TRANSITIONS.csv'), 'TextType', 'string');
    G = readtable(fullfile(tablesDir, 'THESIS_LEGACY_GASLP_CONTEXT.csv'), 'TextType', 'string');
    R = readtable(fullfile(tablesDir, 'THESIS_RECIRCULATION_TIMING_RESULTS.csv'), 'TextType', 'string');
    rootDir = setup_v05_paths();
    C0 = readtable(fullfile(rootDir, '06_manuscript', 'article_Q1', 'review', ...
        'CR1_COMP_01_CANONICAL_DATASET_v96z.csv'), 'TextType', 'string');
    C = C0(C0.source == "CORRECTED_R1", :);

    histLabels = ["YES","NO"];
    currLabels = ["YES","NO"];
    counts = zeros(2,2);
    for i=1:2, for j=1:2
        counts(i,j)=sum(S.HISTORICAL_ND==histLabels(i) & S.CURRENT_ND==currLabels(j));
    end, end
    f=figure('Visible','off','Color','w','Position',[100 100 650 480]);
    imagesc(counts); colormap(f, parula); colorbar;
    xticks(1:2); xticklabels({'Current ND','Current dominated'});
    yticks(1:2); yticklabels({'Historical ND','Historical dominated'});
    for i=1:2, for j=1:2, text(j,i,sprintf('%d',counts(i,j)),'HorizontalAlignment','center','FontSize',14,'FontWeight','bold'); end, end
    title('FIG T1 — Nondominance-status transitions');
    exportgraphics(f,fullfile(figuresDir,'FIG_T1_status_transitions.png'),'Resolution',220); close(f);

    pairs = {'f1','f2';'f1','f3';'f2','f3'};
    f=figure('Visible','off','Color','w','Position',[100 100 1350 430]); tl=tiledlayout(1,3,'Padding','compact');
    nd=T.current_rank==1;
    for k=1:3
        ax=nexttile(tl); hold(ax,'on');
        scatter(ax,T.(pairs{k,1})(~nd),T.(pairs{k,2})(~nd),32,[.65 .65 .65],'filled');
        scatter(ax,T.(pairs{k,1})(nd),T.(pairs{k,2})(nd),42,[0 .45 .70],'filled');
        xlabel(ax,pairs{k,1}); ylabel(ax,pairs{k,2}); grid(ax,'on');
    end
    legend({'Current dominated','Current nondominated'},'Location','best'); title(tl,'FIG T2 — Current objective-space geometry of HB200 designs');
    exportgraphics(f,fullfile(figuresDir,'FIG_T2_thesis_current_geometry.png'),'Resolution',220); close(f);

    f=figure('Visible','off','Color','w','Position',[100 100 1350 430]); tl=tiledlayout(1,3,'Padding','compact');
    cNames={'MR_final','cost_specific_USD_per_kgwater','CO2_specific_kgCO2_per_kgwater'};
    for k=1:3
        ax=nexttile(tl); hold(ax,'on');
        scatter(ax,T.(pairs{k,1})(nd),T.(pairs{k,2})(nd),44,[0 .45 .70],'filled');
        ix=find(strcmp(pairs{k,1},{'f1','f2','f3'})); iy=find(strcmp(pairs{k,2},{'f1','f2','f3'}));
        scatter(ax,C.(cNames{ix}),C.(cNames{iy}),50,[.84 .33 .10],'^','filled');
        xlabel(ax,pairs{k,1}); ylabel(ax,pairs{k,2}); grid(ax,'on');
    end
    legend({'T current ND','Current C'},'Location','best'); title(tl,'FIG T3 — T and C on the common current basis');
    exportgraphics(f,fullfile(figuresDir,'FIG_T3_T_vs_C.png'),'Resolution',220); close(f);

    f=figure('Visible','off','Color','w','Position',[100 100 1350 430]); tl=tiledlayout(1,4,'Padding','compact');
    tVars={T.m_max,T.T_min,T.r_rec,zeros(height(T),1)}; cVars={C.m_max,C.T_min,C.r_div2,C.t_rec_ini}; labels={'m max','T min','r rec','t rec'};
    for k=1:4
        ax=nexttile(tl); hold(ax,'on');
        scatter(ax,ones(size(tVars{k})),tVars{k},24,[0 .45 .70],'filled','jitter','on','jitterAmount',.08);
        scatter(ax,2*ones(size(cVars{k})),cVars{k},30,[.84 .33 .10],'^','filled','jitter','on','jitterAmount',.08);
        xlim(ax,[.5 2.5]); xticks(ax,[1 2]); xticklabels(ax,{'T','C'}); title(ax,labels{k}); grid(ax,'on');
    end
    title(tl,'FIG T4 — Decision provenance and expanded timing control');
    exportgraphics(f,fullfile(figuresDir,'FIG_T4_decision_provenance.png'),'Resolution',220); close(f);

    f=figure('Visible','off','Color','w','Position',[100 100 1250 430]); tl=tiledlayout(1,3,'Padding','compact');
    for k=1:3
        ax=nexttile(tl); vals=[G.([pairs{1,1} '_hybrid']) G.([pairs{1,1} '_gasLP'])]; %#ok<NASGU>
        field=sprintf('f%d',k); vals=[G.([field '_hybrid']) G.([field '_gasLP'])];
        bar(ax,vals); xticks(ax,1:height(G)); xticklabels(ax,G.THESIS_ID); title(ax,field); grid(ax,'on');
    end
    legend({'Hybrid','gas-LPG'},'Location','best'); title(tl,'FIG T5 — Pointwise current gas-LPG context');
    exportgraphics(f,fullfile(figuresDir,'FIG_T5_gasLP_context.png'),'Resolution',220); close(f);

    ids=unique(R.THESIS_ID,'stable');
    f=figure('Visible','off','Color','w','Position',[100 100 1350 430]); tl=tiledlayout(1,3,'Padding','compact');
    for k=1:3
        ax=nexttile(tl); hold(ax,'on'); field=sprintf('f%d',k);
        for j=1:numel(ids)
            rows=R(R.THESIS_ID==ids(j),:); [x,ord]=sort(rows.t_rec_or_historical_equivalent);
            plot(ax,x,rows.(field)(ord),'-o','DisplayName',ids(j));
        end
        xlabel(ax,'t rec (h)'); ylabel(ax,field); grid(ax,'on');
    end
    legend('Location','best'); title(tl,'FIG T6 — Prespecified paired recirculation-timing response');
    exportgraphics(f,fullfile(figuresDir,'FIG_T6_timing_response.png'),'Resolution',220); close(f);
end
