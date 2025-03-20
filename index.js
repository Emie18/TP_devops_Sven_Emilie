exports.handler = async (event) => {
    try {
        console.log("Hi there"); // Cette ligne sera capturÃ©e dans CloudWatch
        // Get current time in Paris (Europe/Paris timezone)
        const parisTime = new Date().toLocaleString('fr-FR', {
            timeZone: 'Europe/Paris',
            dateStyle: 'full',
            timeStyle: 'long'
        });
        
        // Name information
        const firstName = 'Emilie';
        const lastName = 'Tual';
        
        console.log(`Current time in Paris: ${parisTime}`);
        console.log(`Returning name: ${firstName} ${lastName}`);
        // Prepare response
        const response = {
            statusCode: 200,
            body: JSON.stringify({
                message: `Bonjour ${firstName} ${lastName}. Il est ${parisTime}`,
            })
        };
        
        return response;
    } catch (error) {
        return {
            statusCode: 500,
            body: JSON.stringify({
                message: 'Une erreur est survenue',
                error: error.message
            })
        };
    }
};
