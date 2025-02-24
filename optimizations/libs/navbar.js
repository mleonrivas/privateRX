function renderNavBar(divId) {
    document.getElementById(divId).innerHTML = `
        <div class="logo" onclick="go('')">RecoveryX</div>
        <div class="user-section">
            <img src="/optimizations/libs/icon-tests.png" class="user-icon" alt="Tests" onclick="go('')" id="yIcon">
            <img src="/optimizations/libs/icon-opt.png" class="user-icon" alt="Optimization" onclick="go('optimizations')" id="xIcon">
            
        </div>
    `;
}

function go(page) {
    window.location.href = `/${page}`;
}