function [] = SPF_disp(disp_STR)
global SPF_FLAGS;
VERBOSE_FLAG=SPF_FLAGS.VERBOSE;
if VERBOSE_FLAG
    disp(disp_STR);
end
end