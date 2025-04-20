AddGlobalClassPostConstruct("entityscript", "EntityScript", function(self)
    local old_FacePoint = self.FacePoint

    self.FacePoint = function(self, ...)
        if self.sg ~= nil and self.sg:HasStateTag("stariliad_no_face_point") then
            return
        end

        return old_FacePoint(self, ...)
    end
end)
