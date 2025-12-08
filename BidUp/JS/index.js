let allItems = [];
let currentCategory = "all";

document.addEventListener("DOMContentLoaded", () => {
  fetchItems();

  document.getElementById("searchBox").addEventListener("input", filterItems);
  document.getElementById("sortSelect").addEventListener("change", sortItems);

  document.querySelectorAll(".category-btn").forEach((btn) => {
    btn.addEventListener("click", function () {
      document
        .querySelectorAll(".category-btn")
        .forEach((b) => b.classList.remove("active"));
      this.classList.add("active");
      currentCategory = this.dataset.category;
      filterItems();
    });
  });
});

async function fetchItems() {
  try {
    const response = await fetch("get_items.php");
    const data = await response.json();
    if (data.success) {
      allItems = data.data;
      displayItems(allItems);
    } else {
      document.getElementById("itemList").innerHTML = "<p>No items found.</p>";
    }
  } catch (err) {
    console.error("Error loading items:", err);
  }
}

function displayItems(items) {
  const list = document.getElementById("itemList");
  list.innerHTML = "";

  if (items.length === 0) {
    list.innerHTML = "<p>No items available.</p>";
    return;
  }

  items.forEach((item) => {
    const div = document.createElement("div");
    div.className = "item-card";
    div.innerHTML = `
          ${
            item.image_path
              ? `<img src="${item.image_path}" alt="${item.title}">`
              : ""
          }
          <div class="item-header">
            <h3>${item.title}</h3>
            <span class="category-badge">${item.category}</span>
          </div>
          <div class="item-body">
            <p>${item.description}</p>
            <p class="price">₱${parseFloat(item.current_price).toFixed(2)}</p>
            <p class="status">${item.status.toUpperCase()}</p>
          </div>
          ${
            item.status === "active"
              ? `<button onclick="window.location.href='login.html'">Login to Bid</button>`
              : `<button disabled>Ended</button>`
          }
        `;
    list.appendChild(div);
  });
}

function filterItems() {
  const query = document.getElementById("searchBox").value.toLowerCase();
  let filtered = allItems.filter(
    (i) =>
      i.title.toLowerCase().includes(query) ||
      i.description.toLowerCase().includes(query)
  );

  if (currentCategory !== "all") {
    filtered = filtered.filter((i) => i.category === currentCategory);
  }

  displayItems(filtered);
}

function sortItems() {
  const sortBy = document.getElementById("sortSelect").value;
  let sorted = [...allItems];

  if (currentCategory !== "all") {
    sorted = sorted.filter((i) => i.category === currentCategory);
  }

  if (sortBy === "priceAsc")
    sorted.sort((a, b) => a.current_price - b.current_price);
  else if (sortBy === "priceDesc")
    sorted.sort((a, b) => b.current_price - a.current_price);
  else sorted.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

  displayItems(sorted);
}
