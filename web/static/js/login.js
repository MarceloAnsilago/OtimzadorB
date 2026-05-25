const form = document.getElementById("loginForm");
const submitButton = document.getElementById("submitButton");
const buttonText = submitButton.querySelector(".button-text");
const buttonLoader = submitButton.querySelector(".button-loader");
const feedback = document.getElementById("feedback");
const sessionStatus = document.getElementById("sessionStatus");
const statusText = sessionStatus.querySelector(".status-text");

function setLoading(isLoading) {
    submitButton.disabled = isLoading;
    buttonText.classList.toggle("d-none", isLoading);
    buttonLoader.classList.toggle("d-none", !isLoading);
}

function setFeedback(message, type = "") {
    feedback.textContent = message;
    feedback.className = "feedback mt-3";
    if (type) {
        feedback.classList.add(type);
    }
}

function setSessionStatus(data) {
    const connected = Boolean(data?.connected);
    sessionStatus.classList.toggle("is-connected", connected);

    if (!connected) {
        statusText.textContent = "Desconectado";
        return;
    }

    const balanceType = data.balance_type || "N/A";
    const balance = data.balance ?? "--";
    const currency = data.currency || "";
    statusText.textContent = `Conectado | ${balanceType} | ${currency}${balance}`;
}

async function refreshSessionStatus() {
    try {
        const response = await fetch("/api/session");
        if (!response.ok) {
            return;
        }
        const data = await response.json();
        setSessionStatus(data);
    } catch (error) {
        console.error(error);
    }
}

form.addEventListener("submit", async (event) => {
    event.preventDefault();

    const email = form.email.value.trim();
    const password = form.password.value;

    if (!email || !password) {
        setFeedback("Preencha e-mail e senha.", "is-error");
        return;
    }

    try {
        setLoading(true);
        setFeedback("Enviando credenciais para o Flask...");

        const response = await fetch("/login", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email, password }),
        });

        const data = await response.json();
        setFeedback(
            data.message || "Fluxo recebido com sucesso.",
            response.ok ? "is-success" : "is-error",
        );
        setSessionStatus(data.data || {});
        if (response.ok) {
            window.location.href = "/dashboard";
        }
    } catch (error) {
        console.error(error);
        setFeedback("Falha ao enviar os dados para a aplicacao local.", "is-error");
    } finally {
        setLoading(false);
    }
});

refreshSessionStatus();
