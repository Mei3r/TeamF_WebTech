document.getElementById("loginForm").addEventListener("submit", async (e) => {
  e.preventDefault();

  const formData = new FormData();
  formData.append("username", document.getElementById("username").value);
  formData.append("password", document.getElementById("password").value);

  try {
    const response = await fetch("PHP/auth.php", {
      method: "POST",
      body: formData,
    });
    const data = await response.json();

    if (data.success) {
      sessionStorage.setItem("user", JSON.stringify(data.user));

      if (data.user.user_type === "admin") {
        window.location.href = "admin-dashboard.html";
      } else {
        window.location.href = "user-dashboard.html";
      }
    } else {
      document.getElementById("message").textContent =
        data.error || "Invalid login.";
    }
  } catch (err) {
    document.getElementById("message").textContent =
      "Server error. Try again later.";
  }
});
