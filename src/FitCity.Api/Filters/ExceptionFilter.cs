using System.Net;
using FitCity.Application.Exceptions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace FitCity.Api.Filters;

public class ExceptionFilter : ExceptionFilterAttribute
{
    private readonly ILogger<ExceptionFilter> _logger;

    public ExceptionFilter(ILogger<ExceptionFilter> logger)
    {
        _logger = logger;
    }

    public override void OnException(ExceptionContext context)
    {
        _logger.LogError(context.Exception, context.Exception.Message);

        if (context.Exception is ConflictException)
        {
            context.ModelState.AddModelError("userError", context.Exception.Message);
            context.HttpContext.Response.StatusCode = (int)HttpStatusCode.Conflict;
        }
        else if (context.Exception is UserException)
        {
            context.ModelState.AddModelError("userError", context.Exception.Message);
            context.HttpContext.Response.StatusCode = (int)HttpStatusCode.BadRequest;
        }
        else
        {
            context.ModelState.AddModelError("ERROR", "Server side error, please check logs");
            context.HttpContext.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
        }

        var list = context.ModelState.Where(x => x.Value.Errors.Count > 0)
            .ToDictionary(x => x.Key, y => y.Value.Errors.Select(z => z.ErrorMessage));

        var code = (context.Exception as ConflictException)?.Code;
        context.Result = code == null
            ? new JsonResult(new { errors = list })
            : new JsonResult(new { errors = list, code });
    }
}
