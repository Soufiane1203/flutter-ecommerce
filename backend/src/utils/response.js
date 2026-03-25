/**
 * Utilitaires pour la réponse API
 * Standardise les réponses de l'API
 */

/**
 * Réponse de succès standardisée
 */
const successResponse = (res, data, message = 'Succès', statusCode = 200) => {
  res.status(statusCode).json({
    success: true,
    message,
    data,
  });
};

/**
 * Réponse d'erreur standardisée
 */
const errorResponse = (res, message = 'Erreur', statusCode = 500, errors = null) => {
  const response = {
    success: false,
    message,
  };

  if (errors) {
    response.errors = errors;
  }

  res.status(statusCode).json(response);
};

/**
 * Réponse paginée standardisée
 */
const paginatedResponse = (res, data, page, limit, total, message = 'Succès') => {
  const totalPages = Math.ceil(total / limit);

  res.status(200).json({
    success: true,
    message,
    data,
    pagination: {
      currentPage: parseInt(page),
      itemsPerPage: parseInt(limit),
      totalItems: parseInt(total),
      totalPages,
      hasNextPage: page < totalPages,
      hasPreviousPage: page > 1,
    },
  });
};

module.exports = {
  successResponse,
  errorResponse,
  paginatedResponse,
};
