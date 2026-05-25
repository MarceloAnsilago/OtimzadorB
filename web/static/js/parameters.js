const cycleInput = document.getElementById("cycle");
const rangeMaxValueInput = document.getElementById("rangeMaxValue");
const rangeMaxStartInput = document.getElementById("rangeMaxStart");
const rangeMaxStepInput = document.getElementById("rangeMaxStep");
const rangeMaxEndInput = document.getElementById("rangeMaxEnd");
const wickToWickSelect = document.getElementById("wickToWick");
const runOptimizerButton = document.getElementById("runOptimizerButton");
const optimizerFeedback = document.getElementById("optimizerFeedback");
const optimizerMeta = document.getElementById("optimizerMeta");
const optimizerResultsBody = document.getElementById("optimizerResultsBody");

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

function renderEmptyGrid(message) {
    optimizerResultsBody.innerHTML = `
        <tr>
            <td colspan="8" class="empty-state">${message}</td>
        </tr>
    `;
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

    optimizerResultsBody.innerHTML = rows.map((row) => `
        <tr class="result-row" data-param="${row.param}">
            <td>${row.param}</td>
            <td>${row.g0}</td>
            <td>${row.g1}</td>
            <td>${row.g2}</td>
            <td>${row.g3}</td>
            <td>${row.loss}</td>
            <td>${row.ops}</td>
            <td>${row.score}</td>
        </tr>
    `).join("");
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

    try {
        await promoteParameter(Number(row.dataset.param));
    } catch (error) {
        console.error(error);
        setFeedback(error.message || "Falha ao promover parametro.", "is-error");
    }
});

runOptimizerButton.addEventListener("click", async () => {
    const payload = {
        cycle: Number(cycleInput.value),
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
