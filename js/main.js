var emailContainer = document.getElementById('emailContainer');
document.body.addEventListener('click', function(event) {
    // Check if the clicked element is not the emailContainer or a descendant of it
    if (!emailContainer.contains(event.target)) {
        if (emailContainer.classList.contains('visible')) {
            emailContainer.classList.remove('visible');
        } else {
            emailContainer.classList.add('visible');
        }
    }
});

// Event listener for copying the email to the clipboard when emailContainer is clicked
emailContainer.addEventListener('click', function(event) {
    // Prevent the event from propagating to the body
    event.stopPropagation();

    // Copy the email to clipboard
    var emailText = emailContainer.querySelector('p').innerText;
    var textArea = document.createElement('textarea');
    textArea.value = emailText;
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand('copy');
    document.body.removeChild(textArea);

    // Show copy message
    var copyMessage = document.getElementById('copyMessage');
    copyMessage.style.display = 'block';
    copyMessage.style.opacity = '1';
    
    // Hide the message after 2 seconds
    setTimeout(function() {
        copyMessage.style.opacity = '0';
        
        // Remove it from the layout after the fade-out transition is done
        setTimeout(function() {
            copyMessage.style.display = 'none';
        }, 500); // This 500ms should match the transition duration in the CSS

    }, 2000); // The message will be visible for 2 seconds
});
