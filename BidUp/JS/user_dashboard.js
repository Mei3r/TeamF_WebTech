let user = JSON.parse(sessionStorage.getItem("user"));
let allItems = [];
let myItems = [];
let wonItems = [];
let currentView = "all";
let currentCategory = "all";

if (!user) {
  alert("Please log in first.");
  window.location.href = "login.html";
}

document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("userName").textContent = user.full_name;
  fetchAllItems();

  document.getElementById("logoutBtn").addEventListener("click", logout);
  document.getElementById("searchBox").addEventListener("input", filterItems);
  document.getElementById("sortSelect").addEventListener("change", sortItems);
  document
    .getElementById("closeBiddersModal")
    .addEventListener("click", closeBiddersModal);
  document
    .getElementById("closePaymentModal")
    .addEventListener("click", closePaymentModal);

  document
    .getElementById("toggleMyItems")
    .addEventListener("click", showMyItems);
  document
    .getElementById("toggleWonItems")
    .addEventListener("click", showWonItems);
  document
    .getElementById("toggleAllItems")
    .addEventListener("click", showAllItems);

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

  document.getElementById("openAuctionForm").addEventListener("click", () => {
    document.getElementById("auctionFormModal").classList.remove("hidden");
  });

  document.getElementById("closeAuctionForm").addEventListener("click", () => {
    document.getElementById("auctionFormModal").classList.add("hidden");
  });

  document
    .getElementById("auctionForm")
    .addEventListener("submit", submitAuction);
  document
    .getElementById("paymentForm")
    .addEventListener("submit", processPayment);
});

async function fetchAllItems() {
  try {
    const response = await fetch("get_items.php");
    const data = await response.json();
    if (data.success) {
      allItems = data.data;
      if (currentView === "all") {
        displayItems(allItems, "all");
      }
    }
  } catch (err) {
    console.error("Error loading items:", err);
  }
}

async function fetchMyItems() {
  try {
    const response = await fetch("get_my_items.php");
    const data = await response.json();
    if (data.success) {
      myItems = data.data;
      displayItems(myItems, "my");
    } else {
      document.getElementById("itemList").innerHTML =
        "<p>You haven't created any auctions yet.</p>";
    }
  } catch (err) {
    console.error("Error loading my items:", err);
  }
}

async function fetchWonItems() {
  try {
    const response = await fetch("get_won_items.php");
    const data = await response.json();
    if (data.success) {
      wonItems = data.data;
      if (wonItems.length === 0) {
        document.getElementById("itemList").innerHTML =
          "<p>You haven't won any auctions yet.</p>";
      } else {
        displayItems(wonItems, "won");
      }
    } else {
      document.getElementById("itemList").innerHTML =
        "<p>You haven't won any auctions yet.</p>";
    }
  } catch (err) {
    console.error("Error loading won items:", err);
    document.getElementById("itemList").innerHTML =
      "<p>Error loading won items.</p>";
  }
}

function showMyItems() {
  currentView = "my";
  document.getElementById("searchSection").style.display = "none";
  fetchMyItems();
}

function showWonItems() {
  currentView = "won";
  document.getElementById("searchSection").style.display = "none";
  fetchWonItems();
}

function showAllItems() {
  currentView = "all";
  currentCategory = "all";
  document.getElementById("searchSection").style.display = "flex";
  document
    .querySelectorAll(".category-btn")
    .forEach((b) => b.classList.remove("active"));
  document.querySelector('[data-category="all"]').classList.add("active");
  displayItems(allItems, "all");
}

function displayItems(items, viewType) {
  const container = document.getElementById("itemList");
  container.innerHTML = "";

  if (!items || items.length === 0) {
    container.innerHTML = "<p>No items available.</p>";
    return;
  }

  items.forEach((item) => {
    const card = document.createElement("div");
    card.classList.add("item-card");

    const isActive = item.status === "active";
    const isEnded = item.status === "ended";
    const isPending = item.status === "pending";
    const isOwner = item.owner_id === user.user_id;

    let actionButtons = "";

    if (viewType === "my") {
      if (isPending) {
        actionButtons = '<p style="color: #f39c12;">Pending Admin Approval</p>';
      } else if (isActive) {
        actionButtons = `
              <button onclick="endMyAuction(${item.item_id})" style="background: #dc3545;">End Auction</button>
              <button onclick="viewBidders(${item.item_id})">View Bidders</button>
            `;
      } else if (isEnded) {
        const winnerInfo = item.winner_name
          ? `<p>Winner: ${item.winner_name}</p>`
          : "<p>No Winner (No Bids)</p>";
        actionButtons = `
              <p style="color: #28a745;">Auction Ended</p>
              ${winnerInfo}
              <button onclick="viewBidders(${item.item_id})">View Bidders</button>
            `;
      }
    } else if (viewType === "won") {
      const hasPaid = item.payment_id !== null;
      if (hasPaid) {
        actionButtons = `
              <p style="color: #28a745;">Payment Completed</p>
              <p style="font-size: 0.9em;">Transaction: ${item.transaction_ref}</p>
              <p style="font-size: 0.9em;">Seller: ${item.owner_name}</p>
              <p style="font-size: 0.9em;">Contact: ${item.owner_email}</p>
            `;
      } else {
        actionButtons = `
              <p style="color: #dc3545; font-weight: bold;">Payment Required</p>
              <p style="font-size: 0.9em;">Seller: ${item.owner_name}</p>
              <p style="font-size: 0.9em;">Contact: ${item.owner_email}</p>
              <button onclick="openPaymentModal(${
                item.item_id
              }, '${item.title.replace(/'/g, "\\'")}', ${
          item.current_price
        }, '${item.owner_name.replace(/'/g, "\\'")}', '${
          item.owner_email
        }')" style="background: #28a745;">Pay Now</button>
            `;
      }
    } else {
      if (isActive) {
        if (isOwner) {
          actionButtons = `
                <p style="color: #f39c12;">Your Item</p>
                <button onclick="viewBidders(${item.item_id})">View Bidders</button>
              `;
        } else {
          actionButtons = `
                <input type="number" id="bid_${item.item_id}" placeholder="Enter bid" step="0.01" style="padding: 8px; margin-bottom: 8px; width: 100%;">
                <button onclick="placeBid(${item.item_id})" style="background: #28a745;">Place Bid</button>
                <button onclick="viewBidders(${item.item_id})">View Bidders</button>
              `;
        }
      } else if (isEnded) {
        const winnerInfo = item.winner_name
          ? `<p style="font-size: 0.9em;">Winner: ${item.winner_name}</p>`
          : "";
        actionButtons = `
              <p style="color: #dc3545; font-weight: bold;">Auction Ended</p>
              ${winnerInfo}
              <button onclick="viewBidders(${item.item_id})">View Bidders</button>
            `;
      }
    }

    let ownerDisplay = "";
    if (viewType !== "my") {
      ownerDisplay = `<p>Owner: ${item.owner_name || "Unknown"}</p>`;
    }

    card.innerHTML = `
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
            <p>Current: ₱${parseFloat(item.current_price || 0).toFixed(2)}</p>
            <p>Status: ${item.status.toUpperCase()}</p>
            ${ownerDisplay}
          </div>

          <div class="admin-actions">
            ${actionButtons}
          </div>
        `;

    container.appendChild(card);
  });
}

function filterItems() {
  if (currentView !== "all") return;

  const query = document.getElementById("searchBox").value.toLowerCase();
  let filtered = allItems.filter(
    (i) =>
      i.title.toLowerCase().includes(query) ||
      i.description.toLowerCase().includes(query)
  );

  if (currentCategory !== "all") {
    filtered = filtered.filter((i) => i.category === currentCategory);
  }

  displayItems(filtered, "all");
}

function sortItems() {
  if (currentView !== "all") return;

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

  displayItems(sorted, "all");
}

async function endMyAuction(itemId) {
  if (
    !confirm(
      "Are you sure you want to end this auction and announce the winner? The highest bidder will be notified."
    )
  ) {
    return;
  }

  const formData = new FormData();
  formData.append("item_id", itemId);
  formData.append("action", "end");

  try {
    const response = await fetch("update_item_status.php", {
      method: "POST",
      body: formData,
    });
    const data = await response.json();

    if (data.success) {
      alert(data.message);
      fetchMyItems();
    } else {
      alert(data.error);
    }
  } catch (err) {
    alert("Server error while ending auction.");
    console.error(err);
  }
}

async function placeBid(itemId) {
  const bidInput = document.getElementById(`bid_${itemId}`);
  const bidAmount = parseFloat(bidInput.value);

  if (!bidAmount || bidAmount <= 0) {
    alert("Please enter a valid bid amount.");
    return;
  }

  const formData = new FormData();
  formData.append("item_id", itemId);
  formData.append("user_id", user.user_id);
  formData.append("bid_amount", bidAmount);

  try {
    const response = await fetch("place_bid.php", {
      method: "POST",
      body: formData,
    });
    const data = await response.json();

    if (data.success) {
      alert("Bid placed successfully!");
      fetchAllItems();
    } else {
      alert(data.error);
    }
  } catch (err) {
    alert("Server error while placing bid.");
  }
}

async function submitAuction(e) {
  e.preventDefault();
  const formData = new FormData(e.target);
  formData.append("user_id", user.user_id);

  try {
    const response = await fetch("add_item.php", {
      method: "POST",
      body: formData,
    });
    const data = await response.json();

    if (data.success) {
      alert("Item submitted successfully! Waiting for admin approval.");
      document.getElementById("auctionFormModal").classList.add("hidden");
      e.target.reset();
      if (currentView === "my") {
        fetchMyItems();
      }
    } else {
      alert(data.error);
    }
  } catch (err) {
    alert("Server error while submitting item.");
  }
}

function openPaymentModal(itemId, title, amount, ownerName, ownerEmail) {
  document.getElementById("paymentItemId").value = itemId;
  document.getElementById("paymentModalTitle").textContent =
    "Payment for: " + title;

  const content = document.getElementById("paymentContent");
  content.innerHTML = `
        <p><strong>Amount to Pay:</strong> ₱${parseFloat(amount).toFixed(2)}</p>
        <p><strong>${ownerName}</p>
        <p><strong>Contact:</strong> ${ownerEmail}</p>
        <hr>
      `;

  document.getElementById("paymentModal").classList.remove("hidden");
}

function closePaymentModal() {
  document.getElementById("paymentModal").classList.add("hidden");
  document.getElementById("paymentForm").reset();
}

async function processPayment(e) {
  e.preventDefault();

  const formData = new FormData(e.target);

  try {
    const response = await fetch("process_payment.php", {
      method: "POST",
      body: formData,
    });
    const data = await response.json();

    if (data.success) {
      alert(
        "Payment successful! Transaction ref: " +
          data.transaction_ref +
          "\n\nSeller: " +
          data.owner_name +
          "\nContact: " +
          data.owner_email
      );
      closePaymentModal();
      fetchWonItems();
    } else {
      alert("Payment failed: " + data.error);
    }
  } catch (err) {
    alert("Server error while processing payment.");
    console.error(err);
  }
}

async function viewBidders(itemId) {
  try {
    const response = await fetch(`get_bidders.php?item_id=${itemId}`);
    const data = await response.json();

    if (data.success) {
      if (data.data.length === 0) {
        alert("No bids yet for this item.");
        return;
      }

      showBiddersModal(data.item_title, data.data);
    } else {
      alert("Error: " + data.error);
    }
  } catch (err) {
    alert("Server error loading bidders.");
    console.error(err);
  }
}

function showBiddersModal(itemTitle, bidders) {
  const modal = document.getElementById("biddersModal");
  const modalTitle = document.getElementById("modalTitle");
  const content = document.getElementById("biddersContent");

  modalTitle.textContent = `Bidders for: ${itemTitle}`;

  let html = '<table style="width: 100%; border-collapse: collapse;">';
  html +=
    '<tr style="background: #667eea; color: white;"><th style="padding: 10px;">Rank</th><th style="padding: 10px;">Bidder</th><th style="padding: 10px;">Amount</th><th style="padding: 10px;">Date</th></tr>';

  bidders.forEach((b, index) => {
    const date = new Date(b.bid_time);
    const formattedDate = date.toLocaleString();
    const rank = index + 1;
    const rowColor = rank === 1 ? "background: #fff3cd;" : "";

    html += `
          <tr style="border-bottom: 1px solid #ddd; ${rowColor}">
            <td style="padding: 10px; text-align: center;">${
              rank === 1 ? 1 : rank
            }</td>
            <td style="padding: 10px;">${b.full_name}</td>
            <td style="padding: 10px; font-weight: bold;">₱${parseFloat(
              b.bid_amount
            ).toFixed(2)}</td>
            <td style="padding: 10px;">${formattedDate}</td>
          </tr>
        `;
  });

  html += "</table>";
  content.innerHTML = html;

  modal.classList.remove("hidden");
}

function closeBiddersModal() {
  document.getElementById("biddersModal").classList.add("hidden");
}

function logout() {
  sessionStorage.clear();
  window.location.href = "index.html";
}
