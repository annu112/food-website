document.addEventListener("DOMContentLoaded", function () {
    // Search Filter for Admin Data Tables
    const adminSearch = document.getElementById("adminTableSearch");
    if (adminSearch) {
        adminSearch.addEventListener("input", function () {
            const query = this.value.toLowerCase().trim();
            const rows = document.querySelectorAll("table tbody tr");

            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                if (text.includes(query)) {
                    row.style.display = "";
                } else {
                    row.style.display = "none";
                }
            });
        });
    }
});

function updateImgPreview(val) {
    const preview = document.getElementById("imgPreview");
    if (preview && val) {
        preview.src = "../images/" + val;
    }
}

function uploadLaptopImage(input) {
    if (!input.files || !input.files[0]) return;

    const file = input.files[0];
    const uploadStatus = document.getElementById("uploadStatus");
    if (uploadStatus) uploadStatus.textContent = "Uploading image...";

    const reader = new FileReader();
    reader.onload = function (e) {
        const base64 = e.target.result;

        const formData = new URLSearchParams();
        formData.append("fileName", file.name);
        formData.append("base64", base64);

        fetch("upload_image.jsp", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: formData.toString()
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                const imgInput = document.getElementById("image");
                if (imgInput) {
                    imgInput.value = data.fileName;
                }
                updateImgPreview(data.fileName);
                if (uploadStatus) uploadStatus.textContent = "Uploaded: " + data.fileName;
            } else {
                alert("Upload error: " + data.error);
                if (uploadStatus) uploadStatus.textContent = "Upload failed.";
            }
        })
        .catch(err => {
            alert("Upload error: " + err);
            if (uploadStatus) uploadStatus.textContent = "Error uploading file.";
        });
    };
    reader.readAsDataURL(file);
}

function editProduct(id, name, price, category, image) {
    const pidEl = document.getElementById("pid");
    const nameEl = document.getElementById("name");
    const priceEl = document.getElementById("price");
    const catEl = document.getElementById("category");
    const imgEl = document.getElementById("image");

    if (pidEl) pidEl.value = id;
    if (nameEl) nameEl.value = name;
    if (priceEl) priceEl.value = price;
    if (catEl && category) catEl.value = category;
    if (imgEl && image) {
        imgEl.value = image;
        updateImgPreview(image);
    }

    const formHeader = document.getElementById("formHeader");
    if (formHeader) formHeader.textContent = "Edit Product #" + id;

    const cancelBtn = document.getElementById("cancelEditBtn");
    if (cancelBtn) cancelBtn.style.display = "inline-block";

    window.scrollTo({ top: 0, behavior: 'smooth' });
}

function cancelEdit() {
    const pidEl = document.getElementById("pid");
    const nameEl = document.getElementById("name");
    const priceEl = document.getElementById("price");
    const imgEl = document.getElementById("image");

    if (pidEl) pidEl.value = "";
    if (nameEl) nameEl.value = "";
    if (priceEl) priceEl.value = "";
    if (imgEl) {
        imgEl.value = "burger.png";
        updateImgPreview("burger.png");
    }

    const formHeader = document.getElementById("formHeader");
    if (formHeader) formHeader.textContent = "Add New Food Product";

    const cancelBtn = document.getElementById("cancelEditBtn");
    if (cancelBtn) cancelBtn.style.display = "none";
}

function deleteProduct(id) {
    if (confirm("Are you sure you want to delete product #" + id + "?")) {
        window.location = "products.jsp?delete=" + id;
    }
}

function confirmDeleteOrder(id) {
    if (confirm("Are you sure you want to delete order #" + id + "?")) {
        window.location = "orders.jsp?delete=" + id;
    }
}
