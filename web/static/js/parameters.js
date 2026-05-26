const cycleInput = document.getElementById("cycle");
const initialCapitalInput = document.getElementById("initialCapital");
const initialStakeLabel = document.getElementById("initialStakeLabel");
const initialStakeInput = document.getElementById("initialStake");
const payoutInput = document.getElementById("payout");
const stakeModeSelect = document.getElementById("stakeMode");
const rangeMaxValueInput = document.getElementById("rangeMaxValue");
const rangeMaxStartInput = document.getElementById("rangeMaxStart");
const rangeMaxStepInput = document.getElementById("rangeMaxStep");
const rangeMaxEndInput = document.getElementById("rangeMaxEnd");
const wickToWickSelect = document.getElementById("wickToWick");
const runOptimizerButton = document.getElementById("runOptimizerButton");
const optimizerFeedback = document.getElementById("optimizerFeedback");
const optimizerMeta = document.getElementById("optimizerMeta");
const optimizerResultsBody = document.getElementById("optimizerResultsBody");
const performanceSummary = document.getElementById("performanceSummary");
const performanceChartCanvas = document.getElementById("performanceChart");

let optimizerRows = [];
let performanceChart = null;

const degreeHeaders = optimizerResultsBody?.closest("table")?.querySelectorAll("thead th");
if (degreeHeaders && degreeHeaders.length >= 5) {
    degreeHeaders[1].innerHTML = "1&deg;";
    degreeHeaders[2].innerHTML = "2&deg;";
    degreeHeaders[3].innerHTML = "3&deg;";
    degreeHeaders[4].innerHTML = "4&deg;";
}

function setFeedback(message, type = "") {
    optimizerFeedback.textContent = message;
    optimizerFeedback.className = "feedback mt-3";
    if (type) {
        optimizerFeedback.classList.add(type);
    }
}

function setLoading(isLoading) {
    runOptimizerButton.disabled = isLoading;
    runOptimizerButton.textContent = isLoading ? "Testando" : "Testar";
}

function syncStakeLabel() {
    if (!initialStakeLabel) {
        return;
    }
    initialStakeLabel.textContent = stakeModeSelect.value === "percentage"
        ? "Aporte inicial (%)"
        : "Aporte inicial";
}

function renderEmptyGrid(message) {
    optimizerRows = [];
    optimizerResultsBody.innerHTML = `
        <tr>
            <td colspan="11" class="empty-state">${message}</td>
        </tr>
    `;
    clearPerformanceChart();
}

async function promoteParameter(paramValue) {
    const response = await fetch("/api/optimizer/promote", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ param: paramValue }),
    });
    const payload = await response.json();
    if (!response.ok) {
        throw new Error(payload.message || "Falha ao promover parametro.");
    }

    rangeMaxValueInput.value = payload.state.range_max_value;
    setFeedback(payload.message || "Parametro promovido com sucesso.", "is-success");
}

function renderRows(rows) {
    if (!rows?.length) {
        renderEmptyGrid("Nenhum resultado retornado ainda.");
        return;
    }

    optimizerRows = rows;
    optimizerResultsBody.innerHTML = rows.map((row) => `
        <tr class="result-row" data-param="${row.param}">
            <td>${row.param}</td>
            <td>${formatCountPct(row.g0, row.g0_pct)}</td>
            <td>${formatCountPct(row.g1, row.g1_pct)}</td>
            <td>${formatCountPct(row.g2, row.g2_pct)}</td>
            <td>${formatCountPct(row.g3, row.g3_pct)}</td>
            <td>${formatCountPct(row.loss, row.loss_pct)}</td>
            <td>${row.ops}</td>
            <td>${row.win_pct}%</td>
            <td>${row.loss_pct}%</td>
            <td>${row.score}</td>
            <td>${row.ruin_pct}%</td>
        </tr>
    `).join("");

    renderPerformance(rows[0]);
    setSelectedRow(rows[0].param);
}

function formatCountPct(count, pct) {
    return `${count} - ${Number(pct).toFixed(2)}%`;
}

function clearPerformanceChart() {
    if (performanceChart) {
        performanceChart.destroy();
        performanceChart = null;
    }
    if (performanceSummary) {
        performanceSummary.textContent = "Selecione uma configuracao na tabela para visualizar a curva de capital.";
    }
}

function setSelectedRow(paramValue) {
    for (const row of optimizerResultsBody.querySelectorAll(".result-row")) {
        row.classList.toggle("is-selected", Number(row.dataset.param) === Number(paramValue));
    }
}

function buildChartLabels(length) {
    return Array.from({ length }, (_, index) => index);
}

function renderPerformance(row) {
    if (!row || !performanceChartCanvas || typeof Chart === "undefined" || !Array.isArray(row.equity_curve)) {
        clearPerformanceChart();
        return;
    }

    if (performanceChart) {
        performanceChart.destroy();
    }

    const labels = buildChartLabels(row.equity_curve.length);
    performanceChart = new Chart(performanceChartCanvas, {
        type: "line",
        data: {
            labels,
            datasets: [
                {
                    label: `Capital | Param ${row.param}`,
                    data: row.equity_curve,
                    borderColor: "#1ed29b",
                    backgroundColor: "rgba(30, 210, 155, 0.18)",
                    fill: true,
                    pointRadius: 0,
                    borderWidth: 2,
                    tension: 0.15,
                },
            ],
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            animation: false,
            interaction: {
                mode: "index",
                intersect: false,
            },
            plugins: {
                legend: {
                    display: false,
                },
            },
            scales: {
                x: {
                    ticks: {
                        color: "#93a4bf",
                        maxTicksLimit: 10,
                    },
                    grid: {
                        color: "rgba(148, 163, 184, 0.08)",
                    },
                },
                y: {
                    ticks: {
                        color: "#93a4bf",
                    },
                    grid: {
                        color: "rgba(148, 163, 184, 0.08)",
                    },
                },
            },
        },
    });

    if (performanceSummary) {
        performanceSummary.textContent = [
            `Param ${row.param}`,
            `entradas ${row.ops}`,
            `acerto ${Number(row.win_pct).toFixed(2)}%`,
            `loss ${Number(row.loss_pct).toFixed(2)}%`,
            `capital final ${Number(row.final_capital).toFixed(2)}`,
            `minimo ${Number(row.min_capital).toFixed(2)}`,
            `drawdown max ${Number(row.max_drawdown_pct).toFixed(2)}%`,
            `ruina ${Number(row.ruin_pct).toFixed(2)}%`,
        ].join(" | ");
    }
}

optimizerResultsBody.addEventListener("click", async (event) => {
    const target = event.target;
    if (!(target instanceof HTMLElement)) {
        return;
    }

    const row = target.closest(".result-row");
    if (!row) {
        return;
    }

    const selectedRow = optimizerRows.find((item) => Number(item.param) === Number(row.dataset.param));
    renderPerformance(selectedRow);
    setSelectedRow(row.dataset.param);

    try {
        await promoteParameter(Number(row.dataset.param));
    } catch (error) {
        console.error(error);
        setFeedback(error.message || "Falha ao promover parametro.", "is-error");
    }
});

stakeModeSelect.addEventListener("change", syncStakeLabel);
syncStakeLabel();

runOptimizerButton.addEventListener("click", async () => {
    const payload = {
        cycle: Number(cycleInput.value),
        initial_capital: Number(initialCapitalInput.value),
        initial_stake: Number(initialStakeInput.value),
        payout: Number(payoutInput.value),
        stake_mode: stakeModeSelect.value,
        range_max_value: Number(rangeMaxValueInput.value),
        range_max_start: Number(rangeMaxStartInput.value),
        range_max_step: Number(rangeMaxStepInput.value),
        range_max_end: Number(rangeMaxEndInput.value),
        wick_to_wick: wickToWickSelect.value === "true",
    };

    if (payload.range_max_step <= 0) {
        setFeedback("Passo deve ser maior que zero.", "is-error");
        return;
    }
    if (payload.initial_capital <= 0) {
        setFeedback("Capital inicial deve ser maior que zero.", "is-error");
        return;
    }
    if (payload.initial_stake <= 0) {
        setFeedback("Aporte inicial deve ser maior que zero.", "is-error");
        return;
    }
    if (payload.payout < 0) {
        setFeedback("Payout deve ser zero ou maior.", "is-error");
        return;
    }

    try {
        setLoading(true);
        setFeedback("Executando otimizacao progressiva...");
        renderEmptyGrid("Processando resultados...");

        const response = await fetch("/api/optimizer/test", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(payload),
        });
        const result = await response.json();

        if (!response.ok) {
            renderEmptyGrid("Nenhum resultado retornado ainda.");
            setFeedback(result.message || "Falha ao executar a otimizacao.", "is-error");
            return;
        }

        renderRows(result.data.rows || []);
        optimizerMeta.textContent = `${result.data.rows.length} configuracoes avaliadas | ordenado por score DESC`;
        setFeedback(result.message || "Otimizacao concluida.", "is-success");
    } catch (error) {
        console.error(error);
        renderEmptyGrid("Nenhum resultado retornado ainda.");
        setFeedback("Falha ao comunicar com o motor analitico.", "is-error");
    } finally {
        setLoading(false);
    }
});
