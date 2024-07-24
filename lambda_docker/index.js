exports.handler = async (event) => {
    const response = {
        statusCode: 200,
        body: JSON.stringify('Welcome, Lambda Container is working'),
    };
    return response;
};