document.addEventListener("DOMContentLoaded", function () {
    // 1. Navbar Scroll Effect
    const navbar = document.getElementById("navbar");
    if (navbar) {
        window.addEventListener("scroll", function () {
            if (window.scrollY > 40) {
                navbar.classList.add("scrolled");
            } else {
                navbar.classList.remove("scrolled");
            }
        });
    }

    // 2. Shopping Cart System (Multi-Item Dual Persistence Across All Storage Keys)
    const CART_STORAGE_KEYS = ["zk_cart", "z_kitchen_cart", "cart", "cart_items", "food_cart", "user_cart"];

    function getCart() {
        try {
            for (let k of CART_STORAGE_KEYS) {
                let localStr = localStorage.getItem(k) || sessionStorage.getItem(k);
                if (localStr && localStr !== "[]" && localStr !== "null") {
                    let parsed = JSON.parse(localStr);
                    if (Array.isArray(parsed) && parsed.length > 0) {
                        // Normalize across all storage keys
                        const jsonStr = JSON.stringify(parsed);
                        CART_STORAGE_KEYS.forEach(key => {
                            try { localStorage.setItem(key, jsonStr); } catch(e){}
                        });
                        return parsed;
                    }
                }
            }
            // Restore from server session if local storage was empty
            if (window.serverCartJson && Array.isArray(window.serverCartJson) && window.serverCartJson.length > 0) {
                const jsonStr = JSON.stringify(window.serverCartJson);
                CART_STORAGE_KEYS.forEach(key => {
                    try { localStorage.setItem(key, jsonStr); } catch(e){}
                });
                return window.serverCartJson;
            }
            return [];
        } catch (e) {
            console.error("Error reading cart:", e);
            return [];
        }
    }

    function saveCart(cart) {
        try {
            const jsonStr = JSON.stringify(cart);
            CART_STORAGE_KEYS.forEach(key => {
                try { localStorage.setItem(key, jsonStr); } catch(e){}
            });
            updateCartBadges();

            // Dual persistence: sync with Tomcat session via fetch POST
            fetch("sync_cart.jsp", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "cart_json=" + encodeURIComponent(jsonStr)
            }).catch(function(err) {});
        } catch(e) {
            console.error("Error saving cart:", e);
        }
    }

    function updateCartBadges() {
        try {
            const cart = getCart();
            const totalQty = cart.reduce((sum, item) => sum + (parseInt(item.qty) || 1), 0);
            
            const countEls = document.querySelectorAll(".cart-count-badge");
            countEls.forEach(el => {
                el.textContent = totalQty;
                if (totalQty > 0) {
                    el.style.display = "inline-flex";
                } else {
                    el.style.display = "none";
                }
            });

            // Floating Cart Bar Visibility
            const floatBar = document.getElementById("floatingCartBar");
            if (floatBar) {
                if (totalQty > 0) {
                    const totalPrice = cart.reduce((sum, item) => sum + ((parseFloat(item.price) || 0) * (parseInt(item.qty) || 1)), 0);
                    const floatQty = document.getElementById("floatCartQty");
                    const floatTotal = document.getElementById("floatCartTotal");
                    if (floatQty) floatQty.textContent = totalQty + (totalQty === 1 ? " item" : " items");
                    if (floatTotal) floatTotal.textContent = "₹" + totalPrice;
                    floatBar.style.display = "flex";
                } else {
                    floatBar.style.display = "none";
                }
            }
        } catch(e) {
            console.error("Error updating cart badges:", e);
        }
    }

    window.addToCart = function (id, name, price, image, category, redirect) {
        if (!name || !price) return;
        let cart = getCart();
        let existing = cart.find(item => item.name.trim().toLowerCase() === name.trim().toLowerCase());
        if (existing) {
            existing.qty = (parseInt(existing.qty) || 1) + 1;
        } else {
            cart.push({
                id: id ? parseInt(id) : Date.now(),
                name: name.trim(),
                price: parseFloat(price),
                image: image || "pizza.png",
                category: category || "Fast Food",
                qty: 1
            });
        }
        saveCart(cart);

        if (redirect === true) {
            fetch("sync_cart.jsp", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "cart_json=" + encodeURIComponent(JSON.stringify(cart))
            }).then(function() {
                window.location.href = "Order.jsp";
            }).catch(function() {
                window.location.href = "Order.jsp";
            });
        } else {
            showToast("Added " + name + " to Cart!");
            renderOrderPageCart();
        }
    };

    window.updateCartQty = function (index, change) {
        let cart = getCart();
        if (cart[index]) {
            cart[index].qty = (parseInt(cart[index].qty) || 1) + change;
            if (cart[index].qty <= 0) {
                cart.splice(index, 1);
            }
            saveCart(cart);
            renderOrderPageCart();
        }
    };

    window.removeCartItem = function (index) {
        let cart = getCart();
        if (cart[index]) {
            cart.splice(index, 1);
            saveCart(cart);
            renderOrderPageCart();
        }
    };

    window.clearCart = function () {
        CART_STORAGE_KEYS.forEach(key => {
            try {
                localStorage.removeItem(key);
                sessionStorage.removeItem(key);
            } catch(e){}
        });
        try {
            fetch("sync_cart.jsp", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "cart_json=[]"
            }).catch(function(e){});
        } catch(e){}
        updateCartBadges();
        renderOrderPageCart();
    };

    // Expose cart manager globally
    window.cartManager = {
        clearCart: window.clearCart,
        getCart: getCart
    };

    // 3. Menu Search & Category Filter
    const searchInput = document.getElementById("menuSearch");
    const categoryBtns = document.querySelectorAll(".category-tabs .tab-btn");
    const dishCards = document.querySelectorAll(".dish-item-col");

    function filterDishes() {
        try {
            const query = searchInput ? searchInput.value.toLowerCase().trim() : "";
            const activeTab = document.querySelector(".category-tabs .tab-btn.active");
            const category = activeTab && activeTab.getAttribute("data-category") ? activeTab.getAttribute("data-category") : "all";

            dishCards.forEach(card => {
                const name = card.getAttribute("data-name") ? card.getAttribute("data-name").toLowerCase() : "";
                const cat = card.getAttribute("data-category") ? card.getAttribute("data-category").toLowerCase() : "";

                const matchesSearch = name.includes(query);
                const matchesCategory = (category === "all" || cat.includes(category.toLowerCase()));

                if (matchesSearch && matchesCategory) {
                    card.style.display = "block";
                } else {
                    card.style.display = "none";
                }
            });
        } catch(e) {
            console.error("Error filtering dishes:", e);
        }
    }

    if (searchInput) searchInput.addEventListener("input", filterDishes);

    if (categoryBtns.length > 0) {
        categoryBtns.forEach(btn => {
            btn.addEventListener("click", function () {
                categoryBtns.forEach(b => b.classList.remove("active"));
                this.classList.add("active");
                filterDishes();
            });
        });

        try {
            const urlParams = new URLSearchParams(window.location.search);
            const catParam = urlParams.get("cat");
            if (catParam) {
                let matchedBtn = Array.from(categoryBtns).find(btn => {
                    const catAttr = btn.getAttribute("data-category");
                    return catAttr && catAttr.toLowerCase() === catParam.toLowerCase();
                });
                if (matchedBtn) {
                    categoryBtns.forEach(b => b.classList.remove("active"));
                    matchedBtn.classList.add("active");
                }
            }
            filterDishes();
        } catch(e) {
            console.error("Error setting active category tab:", e);
        }
    }

    // 4. Render Multi-Item Order Page Cart & Order Details Table
    function renderOrderPageCart() {
        try {
            const orderDetailsContainer = document.getElementById("checkoutOrderDetailsContainer");
            const cartContainer = document.getElementById("multiItemCartContainer");
            const orderForm = document.getElementById("multiItemOrderForm");
            const emptyNotice = document.getElementById("emptyCartNotice");

            let cart = getCart();

            // Process single item passed via URL query string parameters if any
            try {
                const urlParams = new URLSearchParams(window.location.search);
                const singleId = urlParams.get("id");
                const singleNm = urlParams.get("nm");
                const singleRs = urlParams.get("rs");
                const singleImg = urlParams.get("img");
                const singleCat = urlParams.get("cat") || "Selection";

                if (singleNm && singleRs && parseFloat(singleRs) > 0) {
                    let existing = cart.find(item => item.name.trim().toLowerCase() === singleNm.trim().toLowerCase());
                    if (!existing) {
                        cart.push({
                            id: singleId ? parseInt(singleId) : Date.now(),
                            name: singleNm.trim(),
                            price: parseFloat(singleRs),
                            image: singleImg || "pizza.png",
                            category: singleCat,
                            qty: 1
                        });
                        saveCart(cart);
                    }
                    if (window.history && window.history.replaceState) {
                        const cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
                        window.history.replaceState({ path: cleanUrl }, '', cleanUrl);
                    }
                }
            } catch(e) {}

            if (!cart || cart.length === 0) {
                const emptyHtml = `
                    <div class="card p-4 text-center rounded-4 shadow-sm bg-white border mb-3">
                        <i class="fa-solid fa-cart-shopping display-3 text-muted mb-2"></i>
                        <h4 class="fw-bold text-dark mb-1">Your Shopping Cart is Empty</h4>
                        <p class="text-muted small mb-3">Add some delicious dishes from our menu to place your food order.</p>
                        <div>
                            <a href="Menu.jsp" class="btn btn-danger rounded-pill px-4 py-2 fw-bold shadow-sm">
                                <i class="fa-solid fa-utensils me-2"></i> Browse Menu & Add Food
                            </a>
                        </div>
                    </div>
                `;

                if (orderDetailsContainer) orderDetailsContainer.innerHTML = emptyHtml;
                if (cartContainer) cartContainer.innerHTML = emptyHtml;

                const summaryItemsTotal = document.getElementById("summaryItemsTotal");
                const summaryDeliveryFee = document.getElementById("summaryDeliveryFee");
                const summaryDiscount = document.getElementById("summaryDiscount");
                const summaryGrandTotal = document.getElementById("summaryGrandTotal");

                if (summaryItemsTotal) summaryItemsTotal.textContent = `₹0`;
                if (summaryDeliveryFee) summaryDeliveryFee.textContent = `₹0`;
                if (summaryDiscount) summaryDiscount.textContent = `₹0`;
                if (summaryGrandTotal) summaryGrandTotal.textContent = `₹0`;

                const hiddenNm = document.getElementById("formHiddenNm");
                const hiddenRs = document.getElementById("formHiddenRs");
                const hiddenCartJson = document.getElementById("formHiddenCartJson");

                if (hiddenNm) hiddenNm.value = "";
                if (hiddenRs) hiddenRs.value = "0";
                if (hiddenCartJson) hiddenCartJson.value = "[]";

                updateCartBadges();
                return;
            }

            // Cart HAS items: HIDE empty notice and SHOW checkout order form card
            if (emptyNotice) emptyNotice.style.display = "none";
            if (orderForm) orderForm.style.display = "block";

            let subtotal = 0;
            let summaryNmList = [];

            let itemsTableHtml = `
                <div class="table-responsive rounded-3 border mb-3">
                    <table class="table align-middle mb-0">
                        <thead class="table-light">
                            <tr class="small text-uppercase text-secondary">
                                <th>Item Details</th>
                                <th class="text-center">Qty</th>
                                <th class="text-end">Price</th>
                                <th class="text-end">Subtotal</th>
                                <th class="text-center">Action</th>
                            </tr>
                        </thead>
                        <tbody>
            `;

            cart.forEach((item, index) => {
                const price = parseFloat(item.price) || 0;
                const qty = parseInt(item.qty) || 1;
                const itemTotal = price * qty;
                subtotal += itemTotal;
                summaryNmList.push(item.name + " (x" + qty + ")");

                itemsTableHtml += `
                    <tr>
                        <td>
                            <div class="d-flex align-items-center gap-3">
                                <img src="./images/${item.image || 'pizza.png'}" alt="${item.name}" style="width:48px; height:48px; object-fit:contain;" class="rounded-2 border p-1 bg-white" onerror="this.src='./images/pizza.png'">
                                <div>
                                    <h6 class="mb-0 fw-bold text-dark fs-6">${item.name}</h6>
                                    <small class="text-muted">Item ID: #${item.id || (index+1)} | ₹${price} each</small>
                                </div>
                            </div>
                        </td>
                        <td class="text-center">
                            <div class="qty-counter d-inline-flex align-items-center border rounded-pill bg-white px-2 py-1">
                                <button type="button" class="btn btn-sm p-0 me-2 text-danger border-0 fw-bold" onclick="updateCartQty(${index}, -1)" style="width:24px; height:24px; line-height:1;">-</button>
                                <span class="fw-bold px-2 text-dark fs-6">${qty}</span>
                                <button type="button" class="btn btn-sm p-0 ms-2 text-success border-0 fw-bold" onclick="updateCartQty(${index}, 1)" style="width:24px; height:24px; line-height:1;">+</button>
                            </div>
                        </td>
                        <td class="text-end fw-semibold text-secondary">₹${price}</td>
                        <td class="text-end fw-bold text-danger fs-6">₹${itemTotal}</td>
                        <td class="text-center">
                            <button type="button" class="btn btn-sm btn-outline-danger border-0 rounded-circle" onclick="removeCartItem(${index})" title="Remove item">
                                <i class="fa-solid fa-trash-can"></i>
                            </button>
                        </td>
                    </tr>
                `;
            });

            const deliveryFee = subtotal > 0 ? 40 : 0;
            const discount = 0;
            const grandTotal = subtotal + deliveryFee - discount;

            itemsTableHtml += `
                        </tbody>
                    </table>
                </div>
                
                <div class="p-3 bg-light rounded-3 border">
                    <div class="d-flex justify-content-between mb-1">
                        <span class="text-muted">Items Subtotal (${cart.length} dish${cart.length > 1 ? 'es' : ''})</span>
                        <span class="fw-semibold text-dark">₹${subtotal}</span>
                    </div>
                    <div class="d-flex justify-content-between mb-1">
                        <span class="text-muted">Standard Delivery Charge</span>
                        <span class="fw-semibold text-dark">₹${deliveryFee}</span>
                    </div>
                    <div class="d-flex justify-content-between mb-1">
                        <span class="text-muted">Discount</span>
                        <span class="fw-semibold text-success">₹${discount}</span>
                    </div>
                    <hr class="my-2">
                    <div class="d-flex justify-content-between align-items-center">
                        <span class="fw-bold text-dark fs-6">Cart Total</span>
                        <span class="fw-bold fs-5 text-danger">₹${grandTotal}</span>
                    </div>
                </div>
            `;

            if (orderDetailsContainer) orderDetailsContainer.innerHTML = itemsTableHtml;
            if (cartContainer) cartContainer.innerHTML = itemsTableHtml;

            const summaryItemsTotal = document.getElementById("summaryItemsTotal");
            const summaryDeliveryFee = document.getElementById("summaryDeliveryFee");
            const summaryDiscount = document.getElementById("summaryDiscount");
            const summaryGrandTotal = document.getElementById("summaryGrandTotal");

            if (summaryItemsTotal) summaryItemsTotal.textContent = `₹${subtotal}`;
            if (summaryDeliveryFee) summaryDeliveryFee.textContent = `₹${deliveryFee}`;
            if (summaryDiscount) summaryDiscount.textContent = `₹${discount}`;
            if (summaryGrandTotal) summaryGrandTotal.textContent = `₹${grandTotal}`;

            const hiddenNm = document.getElementById("formHiddenNm");
            const hiddenRs = document.getElementById("formHiddenRs");
            const hiddenCartJson = document.getElementById("formHiddenCartJson");

            if (hiddenNm) hiddenNm.value = summaryNmList.join(", ");
            if (hiddenRs) hiddenRs.value = grandTotal.toString();
            if (hiddenCartJson) hiddenCartJson.value = JSON.stringify(cart);

            updateCartBadges();

            // Ensure session synchronization
            fetch("sync_cart.jsp", {
                method: "POST",
                headers: { "Content-Type": "application/x-www-form-urlencoded" },
                body: "cart_json=" + encodeURIComponent(JSON.stringify(cart))
            }).catch(function(e){});
        } catch(e) {
            console.error("Error rendering order page cart:", e);
        }
    }

    // Expose renderOrderPageCart globally
    window.renderOrderPageCart = renderOrderPageCart;

    // 5. Toast Notification System
    function showToast(message) {
        let toastContainer = document.getElementById("toastContainer");
        if (!toastContainer) {
            toastContainer = document.createElement("div");
            toastContainer.id = "toastContainer";
            toastContainer.style.position = "fixed";
            toastContainer.style.bottom = "25px";
            toastContainer.style.right = "25px";
            toastContainer.style.zIndex = "99999";
            document.body.appendChild(toastContainer);
        }

        const toast = document.createElement("div");
        toast.className = "toast-message shadow-lg rounded-3 p-3 bg-dark text-white d-flex align-items-center mb-2";
        toast.style.minWidth = "250px";
        toast.style.transition = "all 0.3s ease";
        toast.style.opacity = "0";
        toast.style.transform = "translateY(20px)";
        toast.innerHTML = `<i class="fa-solid fa-circle-check text-success fs-5 me-2"></i> <span>${message}</span>`;

        toastContainer.appendChild(toast);

        setTimeout(() => {
            toast.style.opacity = "1";
            toast.style.transform = "translateY(0)";
        }, 10);

        setTimeout(() => {
            toast.style.opacity = "0";
            toast.style.transform = "translateY(20px)";
            setTimeout(() => {
                if (toast.parentNode) toast.parentNode.removeChild(toast);
            }, 300);
        }, 3000);
    }

    // Initial Render
    renderOrderPageCart();
    updateCartBadges();
});
